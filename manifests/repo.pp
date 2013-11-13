# == Class: cloudera::repo
#
# This class handles installing the Cloudera CDH and Impala software
# repositories.
#
# === Parameters:
#
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
#
# [*cdh_yumserver*]
#   URI of the YUM server.
#   Default: http://archive.cloudera.com
#
# [*cdh_yumpath*]
#   The path to add to the $cdh_yumserver URI.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*cdh_version*]
#   The version of Cloudera's Distribution, including Apache Hadoop to install.
#   Default: 4
#
# [*ci_yumserver*]
#   URI of the YUM server.
#   Default: http://archive.cloudera.com
#
# [*ci_yumpath*]
#   The path to add to the $ci_yumserver URI.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*ci_version*]
#   The version of Cloudera Impala to install.
#   Default: 1
#
# [*proxy*]
#   The URL to the proxy server for the YUM repositories.
#   Default: absent
#
# [*proxy_username*]
#   The username for the YUM proxy.
#   Default: absent
#
# [*proxy_password*]
#   The password for the YUM proxy.
#   Default: absent
#
# === Actions:
#
# Installs YUM repository configuration files.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#   class { 'cloudera::repo':
#     cdh_version => '4.1',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
class cloudera::repo (
  $ensure         = $cloudera::params::ensure,
  $cdh_yumserver  = $cloudera::params::cdh_yumserver,
  $cdh_yumpath    = $cloudera::params::cdh_yumpath,
  $cdh_version    = $cloudera::params::cdh_version,
  $ci_yumserver   = $cloudera::params::ci_yumserver,
  $ci_yumpath     = $cloudera::params::ci_yumpath,
  $ci_version     = $cloudera::params::ci_version,
  $proxy          = $cloudera::params::proxy,
  $proxy_username = $cloudera::params::proxy_username,
  $proxy_password = $cloudera::params::proxy_password
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
    yumrepo { 'cloudera-cdh4':
      descr          => 'Cloudera\'s Distribution for Hadoop, Version 4',
      enabled        => $enabled,
      gpgcheck       => 1,
      gpgkey         => "${cdh_yumserver}${cdh_yumpath}RPM-GPG-KEY-cloudera",
      baseurl        => "${cdh_yumserver}${cdh_yumpath}${cdh_version}/",
      priority       => $cloudera::params::yum_priority,
      protect        => $cloudera::params::yum_protect,
      proxy          => $proxy,
      proxy_username => $proxy_username,
      proxy_password => $proxy_password,
    }
    yumrepo { 'cloudera-impala':
      descr          => 'Impala',
      enabled        => $enabled,
      gpgcheck       => 1,
      gpgkey         => "${ci_yumserver}${ci_yumpath}RPM-GPG-KEY-cloudera",
      baseurl        => "${ci_yumserver}${ci_yumpath}${ci_version}/",
      priority       => $cloudera::params::yum_priority,
      protect        => $cloudera::params::yum_protect,
      proxy          => $proxy,
      proxy_username => $proxy_username,
      proxy_password => $proxy_password,
    }
  } elsif $::operatingsystem == 'Ubuntu' {
    Apt::Source {
      key          => $cloudera::params::apt_key, 
      key_server   => $cloudera::params::apt_key_server,
      repos        => 'contrib',
      architecture => $::architecture,
      ensure       => $ensure, 
    }
    apt::source { 'cloudera':      
      location     => "${cloudera::params::aptserver}/cdh4/ubuntu/${::lsbdistcodename}/${::architecture}/cdh",
      release      => "${::lsbdistcodename}-cdh4",
    }
    apt::source { 'impala':      
      location     => "${cloudera::params::aptserver}/impala/ubuntu/${::lsbdistcodename}/${::architecture}/impala",
      release      => "${::lsbdistcodename}-impala1",
    }
    apt::source { 'clouderaextras':    
      location     => "${cloudera::params::aptserver}/gplextras/ubuntu/${::lsbdistcodename}/${::architecture}/gplextras",
      release      => "${::lsbdistcodename}-gplextras4",
    }
  } else {
    fail("Class['cloudera::repo']: Unsupported operatingsystem: ${::operatingsystem}")
  }
}
