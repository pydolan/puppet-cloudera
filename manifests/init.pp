# == Class: cloudera
#
# This class handles installing the Cloudera software with the intention
# of the CDH stack being managed by Cloudera Manager.
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
# [*service_ensure*]
#   Ensure if service is running or stopped.
#   Default: running
#
# [*service_enable*]
#   Start service at boot.
#   Default: true
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
# [*cm_yumserver*]
#   URI of the YUM server.
#   Default: http://archive.cloudera.com
#
# [*cm_yumpath*]
#   The path to add to the $cm_yumserver URI.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*cm_version*]
#   The version of Cloudera Manager to install.
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
# [*cm_server_host*]
#   Hostname of the Cloudera Manager server.
#   Default: localhost
#
# [*cm_server_port*]
#   Port to which the Cloudera Manager server is listening.
#   Default: 7182
#
# [*use_tls*]
#   Whether to enable TLS on the Cloudera Manager agent. TLS needs to be enabled
#   on the server prior to setting this to true.
#   Default: false
#
# [*verify_cert_file*]
#   The file holding the public key of the Cloudera Manager server as well as
#   the chain of signing certificate authorities. PEM format.
#   Default: /etc/pki/tls/certs/cloudera_manager.crt
#
# [*use_parcels*]
#   Whether to use parcel format software install and not RPM.
#   Default: false
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
#   class { 'cloudera':
#     cdh_version    => '4.1',
#     cm_version     => '4.1',
#     cm_server_host => 'smhost.example.com',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#  Copyright (c) 2011, Cloudera, Inc. All Rights Reserved.
#
#  Cloudera, Inc. licenses this file to you under the Apache License,
#  Version 2.0 (the "License"). You may not use this file except in
#  compliance with the License. You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  This software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#  CONDITIONS OF ANY KIND, either express or implied. See the License for
#  the specific language governing permissions and limitations under the
#  License.
#
class cloudera (
  $ensure           = $cloudera::params::ensure,
  $autoupgrade      = $cloudera::params::safe_autoupgrade,
  $service_ensure   = $cloudera::params::service_ensure,
  $service_enable   = $cloudera::params::safe_service_enable,
  $cdh_yumserver    = $cloudera::params::cdh_yumserver,
  $cdh_yumpath      = $cloudera::params::cdh_yumpath,
  $cdh_version      = $cloudera::params::cdh_version,
  $cm_yumserver     = $cloudera::params::cm_yumserver,
  $cm_yumpath       = $cloudera::params::cm_yumpath,
  $cm_version       = $cloudera::params::cm_version,
  $ci_yumserver     = $cloudera::params::ci_yumserver,
  $ci_yumpath       = $cloudera::params::ci_yumpath,
  $ci_version       = $cloudera::params::ci_version,
  $cm_server_host   = $cloudera::params::cm_server_host,
  $cm_server_port   = $cloudera::params::cm_server_port,
  $use_tls          = $cloudera::params::safe_cm_use_tls,
  $verify_cert_file = $cloudera::params::verify_cert_file,
  $use_parcels      = $cloudera::params::safe_use_parcels,
  $proxy            = $cloudera::params::proxy,
  $proxy_username   = $cloudera::params::proxy_username,
  $proxy_password   = $cloudera::params::proxy_password
) inherits cloudera::params {
  # Validate our booleans
  validate_bool($autoupgrade)
  validate_bool($service_enable)
  validate_bool($use_tls)
  validate_bool($use_parcels)

  # temporarily putting keys here for debugging (TODO: move to repo.pp files)
  apt::key { 'oracle-java':
    key          => 'EEA14886',
    key_server   => 'keyserver.ubuntu.com',
  }
  apt::key { 'cloudera':
    key          => 'EEA14886',
    key_server   => 'keyserver.ubuntu.com',
  }  
  
  anchor { 'cloudera::begin': }
  anchor { 'cloudera::end': }

  class { 'cloudera::java::repo':
    ensure      => $ensure,
  }
  class { 'cloudera::java':
    ensure      => $ensure,
    autoupgrade => $autoupgrade,
  }
  class { 'cloudera::cm':
    ensure           => $ensure,
    autoupgrade      => $autoupgrade,
    service_ensure   => $service_ensure,
#    service_enable   => $service_enable,
    server_host      => $cm_server_host,
    server_port      => $cm_server_port,
    use_tls          => $use_tls,
    verify_cert_file => $verify_cert_file,
  }
  # Skip installing the CDH RPMs if we are going to use parcels.
  if $use_parcels {
    class { 'cloudera::cm::repo':
      ensure         => $ensure,
      cm_yumserver   => $cm_yumserver,
      cm_yumpath     => $cm_yumpath,
      cm_version     => $cm_version,
      proxy          => $proxy,
      proxy_username => $proxy_username,
      proxy_password => $proxy_password,
    }
    Anchor['cloudera::begin'] ->
    Class['cloudera::cm::repo'] ->
    Class['cloudera::java::repo'] ->
    Class['cloudera::java'] ->
    Class['cloudera::cm'] ->
    Anchor['cloudera::end']
  } else {
    class { 'cloudera::repo':
      ensure         => $ensure,
      cdh_yumserver  => $cdh_yumserver,
      ci_yumserver   => $ci_yumserver,
      cdh_yumpath    => $cdh_yumpath,
      ci_yumpath     => $ci_yumpath,
      cdh_version    => $cdh_version,
      ci_version     => $ci_version,
      proxy          => $proxy,
      proxy_username => $proxy_username,
      proxy_password => $proxy_password,
    }
    class { 'cloudera::cm::repo':
      ensure         => $ensure,
      cm_yumserver   => $cm_yumserver,
      cm_yumpath     => $cm_yumpath,
      cm_version     => $cm_version,
      proxy          => $proxy,
      proxy_username => $proxy_username,
      proxy_password => $proxy_password,
    }
    class { 'cloudera::cdh':
      ensure         => $ensure,
      autoupgrade    => $autoupgrade,
      service_ensure => $service_ensure,
#      service_enable => $service_enable,
    }
    Anchor['cloudera::begin'] ->
    Class['cloudera::cm::repo'] ->
    Class['cloudera::repo'] ->
    Class['cloudera::java::repo'] ->
    Class['cloudera::java'] ->
    Class['cloudera::cdh'] ->
    Class['cloudera::cm'] ->
    Anchor['cloudera::end']
  }
}
