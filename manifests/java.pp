# == Class: cloudera::java
#
# This class handles installing Oracle JDK as shipped by Cloudera.
#
# === Parameters:
#
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
#
# [*autoupgrade*]
#   Upgrade package automatically, if there is a newer version.
#   Default: false
#
# === Actions:
#
# Installs the Oracle JDK.
# Configures the $JAVA_HOME variable and adds java to the $PATH.
# Configures the alternatives system to set the Oracle JDK as the primary java
# runtime.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#   class { 'cloudera::java': }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
class cloudera::java (
  $ensure      = $cloudera::params::ensure,
  $autoupgrade = $cloudera::params::safe_autoupgrade
) inherits cloudera::params {
  # Validate our booleans
  validate_bool($autoupgrade)

  case $ensure {
    /(present)/: {
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }

      $file_ensure = 'present'
    }
    /(absent)/: {
      $package_ensure = 'absent'
      $file_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }
  
  if $::osfamily == 'RedHat' {  
    package { 'jdk':
      ensure => $package_ensure,
    }
  
    file { 'java-profile.d':
      ensure  => $file_ensure,
      path    => '/etc/profile.d/java.sh',
      source  => 'puppet:///modules/cloudera/java.sh',
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
    }
  
    # http://biowiki.org/CentosAlternatives
    # alternatives --install /usr/bin/java java /usr/java/default/jre/bin/java 1600 \
    #  --slave /usr/bin/keytool keytool /usr/java/default/bin/keytool \
    #  --slave /usr/bin/rmiregistry rmiregistry /usr/java/default/bin/rmiregistry \
    #  --slave /usr/lib/jvm/jre jre /usr/java/default/jre \
    #  --slave /usr/lib/jvm-exports/jre jre_exports /usr/java/default/jre/lib
    exec { 'java-alternatives':
      command => 'alternatives --install /usr/bin/java java /usr/java/default/jre/bin/java 1600 --slave /usr/bin/keytool keytool /usr/java/default/bin/keytool --slave /usr/bin/rmiregistry rmiregistry /usr/java/default/bin/rmiregistry --slave /usr/lib/jvm/jre jre /usr/java/default/jre --slave /usr/lib/jvm-exports/jre jre_exports /usr/java/default/jre/lib',
      unless  => 'alternatives --display java | grep -q /usr/java/default/jre/bin/java',
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      require => Package['jdk'],
      returns => [ 0, 2, ],
    }
  } elsif $::operatingsystem == 'Ubuntu' {
    # adding apt repo since Oracle Java no longer supported by Ubuntu 11+
    apt::source { 'oracle-java':      
      key          => 'EEA14886', 
      key_server   => 'keyserver.ubuntu.com',
      release      => $::lsbdistcodename,
      repos        => 'main',
      ensure       => $ensure, 
      location     => "http://ppa.launchpad.net/webupd8team/java/ubuntu",
    }
    
    # pre-agreeing to user license agreement
    exec { 'oracle-sun-user-agree':
      command => "echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections",
      require => Apt::Source['oracle-java'],
    }
    
    # installing java and jdk package
    package { 'oracle-java7-installer':
      ensure  => $package_ensure,
      require => Exec['oracle-sun-user-agree'],
    }
  } else {
    fail("Class['cloudera::repo']: Unsupported operatingsystem: ${::operatingsystem}")
  }
}
