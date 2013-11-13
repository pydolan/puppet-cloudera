# == Class: cloudera::params
#
# This class handles OS-specific configuration of the cloudera module.  It
# looks for variables in top scope (probably from an ENC such as Dashboard).  If
# the variable doesn't exist in top scope, it falls back to a hard coded default
# value.
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
class cloudera::params {
  # Customize these values if you (for example) mirror public YUM repos to your
  # internal network.
  $yum_priority = '50'
  $yum_protect = '0'

  # If we have a top scope variable defined, use it, otherwise fall back to a
  # hardcoded value.
  $cdh_yumserver = $::cloudera_cdh_yumserver ? {
    undef   => 'http://archive.cloudera.com',
    default => $::cloudera_cdh_yumserver,
  }

  $cm_yumserver = $::cloudera_cm_yumserver ? {
    undef   => 'http://archive.cloudera.com',
    default => $::cloudera_cm_yumserver,
  }

  $ci_yumserver = $::cloudera_ci_yumserver ? {
    undef   => 'http://archive.cloudera.com',
    default => $::cloudera_ci_yumserver,
  }

  $cm_server_host = $::cloudera_cm_server_host ? {
    undef   => 'localhost',
    default => $::cloudera_cm_server_host,
  }

  $cm_server_port = $::cloudera_cm_server_port ? {
    undef   => '7182',
    default => $::cloudera_cm_server_port,
  }

  $verify_cert_file = $::cloudera_verify_cert_file ? {
    undef   => '/etc/pki/tls/certs/cloudera_manager.crt',
    default => $::cloudera_verify_cert_file,
  }

  $server_ca_file = $::cloudera_server_ca_file ? {
    undef   => '/etc/pki/tls/certs/cloudera_manager-ca.crt',
    default => $::cloudera_server_ca_file,
  }

  $server_cert_file = $::cloudera_server_cert_file ? {
    undef   => "/etc/pki/tls/certs/${::fqdn}-cloudera_manager.crt",
    default => $::cloudera_server_cert_file,
  }

  $server_key_file = $::cloudera_server_key_file ? {
    undef   => "/etc/pki/tls/private/${::fqdn}-cloudera_manager.key",
    default => $::cloudera_server_key_file,
  }

  $server_chain_file = $::cloudera_server_chain_file ? {
    undef   => undef,
    default => $::cloudera_server_chain_file,
  }

  $server_keypw = $::cloudera_server_keypw ? {
    undef   => undef,
    default => $::cloudera_server_keypw,
  }

  $oozie_ext = $::cloudera_oozie_ext ? {
    undef   => 'http://archive.cloudera.com/gplextras/misc/ext-2.2.zip',
    default => $::cloudera_oozie_ext,
  }

### The following parameters should not need to be changed.

  $ensure = $::cloudera_ensure ? {
    undef => 'present',
    default => $::cloudera_ensure,
  }

  $service_ensure = $::cloudera_service_ensure ? {
    undef => 'running',
    default => $::cloudera_service_ensure,
  }

  $proxy = $::cloudera_proxy ? {
    undef => 'absent',
    default => $::cloudera_proxy,
  }

  $proxy_username = $::cloudera_proxy_username ? {
    undef => 'absent',
    default => $::cloudera_proxy_username,
  }

  $proxy_password = $::cloudera_proxy_password ? {
    undef => 'absent',
    default => $::cloudera_proxy_password,
  }

  # Since the top scope variable could be a string (if from an ENC), we might
  # need to convert it to a boolean.
  $autoupgrade = $::cloudera_autoupgrade ? {
    undef => false,
    default => $::cloudera_autoupgrade,
  }
  if is_string($autoupgrade) {
    $safe_autoupgrade = str2bool($autoupgrade)
  } else {
    $safe_autoupgrade = $autoupgrade
  }

  $service_enable = $::cloudera_service_enable ? {
    undef => true,
    default => $::cloudera_service_enable,
  }
  if is_string($service_enable) {
    $safe_service_enable = str2bool($service_enable)
  } else {
    $safe_service_enable = $service_enable
  }

  $cm_use_tls = $::cloudera_cm_use_tls ? {
    undef => false,
    default => $::cloudera_cm_use_tls,
  }
  if is_string($cm_use_tls) {
    $safe_cm_use_tls = str2bool($cm_use_tls)
  } else {
    $safe_cm_use_tls = $cm_use_tls
  }

  $use_parcels = $::cloudera_use_parcels ? {
    undef => false,
    default => $::cloudera_use_parcels,
  }
  if is_string($use_parcels) {
    $safe_use_parcels = str2bool($use_parcels)
  } else {
    $safe_use_parcels = $use_parcels
  }

  $cdh_version = '4'
  $cm_version  = '4'
  $ci_version  = '1'

  if $::osfamily == 'RedHat' {
    $cdh_yumpath = "/cdh4/redhat/${::os_maj_version}/${::architecture}/cdh/"
    $cm_yumpath = "/cm4/redhat/${::os_maj_version}/${::architecture}/cm/"
    $ci_yumpath = "/impala/redhat/${::os_maj_version}/${::architecture}/impala/"
    $service = '/sbin/service'
    $apt_key = ''
    $apt_key_server = ''
    $aptserver = ''
  } elsif $::operatingsystem == 'Ubuntu' {
    $cdh_yumpath = ''
    $cm_yumpath = ''
    $ci_yumpath = ''
    $service = '/usr/sbin/service'
    $apt_key = '02A818DD'
    $apt_key_server = 'pgp.mit.edu'          
    $aptserver = 'http://archive.cloudera.com'
  } else {
    fail("Class['cloudera::params']: Unsupported operatingsystem: ${::operatingsystem}")
  }
}
