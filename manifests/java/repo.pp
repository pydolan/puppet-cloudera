# == Class: cloudera::java::repo
#
# This class handles installing the Java Oracle software repositories.
#
# === Parameters:
#
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
#
# === Actions:
#
# Installs repository configuration files.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#   class { 'cloudera::java::repo': }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
class cloudera::java::repo (
  $ensure         = $cloudera::params::ensure
) inherits cloudera::params {
  case $ensure {
    /(present)/: {
      $enabled = '1'
    }
    /(absent)/: {
      $enabled = '0'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  if $::osfamily == 'RedHat' {
    info("***** RedHat family doesn't need to add repo; instead it gets Java from shell script ****")
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
  } else {
    fail("Class['cloudera::java::repo']: Unsupported operatingsystem: ${::operatingsystem}")
  }
}