Puppet Cloudera Manager and CDH4 Module
=======================================

master branch: [![Build Status](https://secure.travis-ci.org/razorsedge/puppet-cloudera.png?branch=master)](http://travis-ci.org/razorsedge/puppet-cloudera)
develop branch: [![Build Status](https://secure.travis-ci.org/razorsedge/puppet-cloudera.png?branch=develop)](http://travis-ci.org/razorsedge/puppet-cloudera)

Introduction
------------

This module manages the installation of [Cloudera's Distribution, including Apache Hadoop (CDH)](http://www.cloudera.com/content/cloudera/en/products/cdh.html) and [Cloudera Manager](http://www.cloudera.com/content/cloudera/en/products/cloudera-manager.html).  It follows the standards written in the [Cloudera Manager Installation Guide](https://ccp.cloudera.com/display/ENT41DOC/Cloudera+Manager+Installation+Guide) [Installation Path B - Installation Using Your Own Method](https://ccp.cloudera.com/display/ENT41DOC/Installation+Path+B+-+Installation+Using+Your+Own+Method).  It also includes installing [Cloudera Impala](http://www.cloudera.com/content/cloudera-content/cloudera-docs/Impala/latest/Installing-and-Using-Impala/Installing-and-Using-Impala.html).

Actions:

* Installs the Cloudera software repositories for CDH, CM, and Impala.
* Installs Oracle JDK 6.
* Installs most components of CDH 4.
* Installs CM 4 agent.
* Installs Impala 1.
* Configures the CM agent to talk to a CM server.
* Starts the CM agent.
* Separately installs the CM server and database connectivity (by default to the embedded database server).
* Separately starts the CM server.

Software Support:

* CDH              - tested with 4.1.2; CDH3 is presently unsuported (patches welcome)
* Cloudera Manager - tested with 4.1.2

OS Support:

* RedHat family - tested on CentOS 6.3
* SuSE family   - presently unsupported (patches welcome)
* Debian family - partially supported on Ubuntu 12.04; see TODO below (more patches welcome)

Class documentation is available via puppetdoc.

Class Descriptions
------------------

### Class['cloudera']

Meta-class that includes:
* Class['cloudera::cm::repo']
* Class['cloudera::repo']
* Class['cloudera::java']
* Class['cloudera::cdh']
* Class['cloudera::cm']

Requires the parameter `cm_server_host`.

### Class['cloudera::repo']

This class handles installing the Cloudera Hadoop and Impala software repositories.

### Class['cloudera::cm::repo']

This class handles installing the Cloudera Manager software repository.

### Class['cloudera::java']

This class handles installing the Oracle JDK from the Cloudera Manager repository.

### Class['cloudera::java::jce']

This class handles installing the Oracle Java Cryptography Extension (JCE) unlimited strength jurisdiction policy files.  Manual setup is requied in order to download the required software from Oracle.  See the files/README_JCE.md file for details.

### Class['cloudera::cdh']

This class handles installing the Cloudera Distribution, including Apache Hadoop.  No configuration is performed on the CDH software and all daemons are forced off so that Cloudera Manager can manage them.  This class installs Bigtop utils, Hadoop (HDFS, MapReduce, YARN), Hue-plugins, HBase, Hive, Oozie, Pig, ZooKeeper, Flume-NG, and Impala.

### Class['cloudera::cdh::hue']

This class handles installing Hue.  This class is not currently included in Class['cloudera::cdh'] as this would conflict with the Cloudera installation instructions.

### Class['cloudera::cm']

This class handles installing and configuring the Cloudera Manager Agent.  This agent should be running on every node in the cluster so that Cloudera Manager can deploy software configurations to the node.  Requires the parameter `server_host` which is passed in from Class['cloudera'].

### Class['cloudera::cm::server']

This class handles installing and configuring the Cloudera Manager Server.  This class should only be included on one node of your environment.  By default it will install the embeded PostgreSQL database on the same node.  With the correct parameters, it can also connect to local or remote MySQL, PostgreSQL, and Oracle RDBMS databases.


Examples
--------

Most nodes in the cluster will use this declaration:
```puppet
class { 'cloudera':
  cm_server_host => 'smhost.example.com',
}
```

Nodes that will be Gateways may use this declaration:
```puppet
class { 'cloudera':
  cm_server_host => 'smhost.example.com',
}
class { 'cloudera::cdh::hue': }
class { 'cloudera::cdh::mahout': }
class { 'cloudera::cdh::sqoop': }
# Install Oozie WebUI support (optional):
#class { 'cloudera::cdh::oozie::ext': }
# Install MySQL support (optional):
#class { 'cloudera::cdh::hue::mysql': }
#class { 'cloudera::cdh::oozie::mysql': }
```

The node that will be the CM server may use this declaration:
(This will skip installation of the CDH software as it is not required.)
```puppet
class { 'cloudera::repo':
  cdh_version => '4.1',
  cm_version  => '4.1',
} ->
class { 'cloudera::java': } ->
class { 'cloudera::java::jce': } ->
class { 'cloudera::cm': } ->
class { 'cloudera::cm::server': }
```

### Parcels

[Parcel](http://blog.cloudera.com/blog/2013/05/faq-understanding-the-parcel-binary-distribution-format/) is an alternative binary distribution format supported by Cloudera Manager 4.5+ that simplifies distribution of CDH and other Cloudera products.  To allow Cloudera Manager to install parcels instead of RPMs, just set `use_parcels => true`.

Nodes that will be cluster members or Gateways will use this declaration:
```puppet
class { 'cloudera':
  cm_server_host => 'smhost.example.com',
  use_parcels    => true,
}
```

The node that will be the CM server may use this declaration:
```puppet
class { 'cloudera':
  cm_server_host => 'smhost.example.com',
  use_parcels    => true,
} ->
class { 'cloudera::cm::server': }
```

### TLS
Level 1: [Configuring TLS Encryption only for Cloudera Manager](http://www.cloudera.com/content/cloudera-content/cloudera-docs/CM4Ent/latest/Cloudera-Manager-Administration-Guide/cmag_config_tls_encr.html)  
Level 2: [Configuring TLS Authentication of Server to Agents and Users](http://www.cloudera.com/content/cloudera-content/cloudera-docs/CM4Ent/latest/Cloudera-Manager-Administration-Guide/cmag_config_tls_auth.html)  
Level 3: [Configuring TLS Authentication of Agents to Server](http://www.cloudera.com/content/cloudera-content/cloudera-docs/CM4Ent/latest/Cloudera-Manager-Administration-Guide/cmag_config_tls_agent_auth.html)

This module's deployment of TLS provides both level 1 and level 2 configuration (encryption and authentication of the server to the agents).  Level 3 is presently much more difficult to implement.  You will need to provide a TLS certificate and the signing certificate authority for the CM server.  See the File resources in the below example for where the files need to be deployed.

There are some settings inside CM that can only be configured manually.  See the [Level 1](http://www.cloudera.com/content/cloudera-content/cloudera-docs/CM4Ent/latest/Cloudera-Manager-Administration-Guide/cmag_config_tls_encr.html) instructions for the details of what to change in the WebUI and use the below values:

    Setting                       Value
    Use TLS Encryption for Agents (check)
    Path to TLS Keystore File     /etc/cloudera-scm-server/keystore
    Keystore Password             The value of server_keypw in Class['cloudera::cm::server'].
    Use TLS Encryption for        (check)
      Admin Console

```puppet
# The node that will be the CM agent may use this declaration:
class { 'cloudera':
  server_host => 'smhost.example.com',
  use_tls     => true,
} ->
class { 'cloudera::java::jce': }
file { '/etc/pki/tls/certs/cloudera_manager.crt': }
```

```puppet
# The node that will be the CM server may use this declaration:
class { 'cloudera':
  server_host => 'smhost.example.com',
  use_tls     => true,
} ->
class { 'cloudera::java::jce': } ->
class { 'cloudera::cm::server':
  use_tls      => true,
  server_keypw => 'myPassWord',
}
file { '/etc/pki/tls/certs/cloudera_manager.crt': }
file { '/etc/pki/tls/certs/cloudera_manager-ca.crt': }
file { "/etc/pki/tls/certs/${::fqdn}-cloudera_manager.crt": }
file { "/etc/pki/tls/private/${::fqdn}-cloudera_manager.key": }
```

Notes
-----

* Supports Top Scope variables (i.e. via Dashboard) and Parameterized Classes.
* Installing CDH3 is not presently supported.
* Based on the [Cloudera Manager 4.1 Installation Guide](https://ccp.cloudera.com/download/attachments/22151983/CM-4.1-enterprise-install-guide.pdf?version=3&modificationDate=1358553325305)
* TLS certificates must be in PEM format and are not deployed by this module.
* When using parcels, the CDH software is not deployed by Puppet.  Puppet will only install the Cloudera Manager server/agent.  You must then configure Cloudera Manager to deploy the parcels.

Issues
------

* Need external module support for the Oracle Instant Client JDBC.

TODO
----

* Add HDFS FUSE mounting support.
* Support pig-udf installation.
* Document hive-server installation.
* Document hive-metastore installation.
* Document sqoop-metastore installation.
* Document whirr installation.
* Debian support: make sure JCE works.
* Debian support: move CM repo into cm/repo.pp.
* Debian support: test Debian OS's other than Ubuntu 12.04.

Contributing
------------

Please see DEVELOP.md for contribution information.

License
-------

Please see LICENSE file.

Copyright
---------

Copyright (C) 2013 Mike Arnold <mike@razorsedge.org>

[razorsedge/puppet-cloudera on GitHub](https://github.com/razorsedge/puppet-cloudera)

[razorsedge/cloudera on Puppet Forge](http://forge.puppetlabs.com/razorsedge/cloudera)

