# tomcat

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with tomcat](#setup)
    * [Setup requirements](#requirements)
    * [Beginning with tomcat](#beginning-with-tomcat)
4. [Usage - Configuration options and additional functionality](#usage)
    * [I want to run multiple instances of multiple versions of Tomcat](#i-want-to-run-multiple-instances-of-multiple-versions-of-tomcat)
    * [I want to deploy WAR files.](#i-want-to-deploy-war-files)
    * [I want to remove some configuration](#i-want-to-remove-some-configuration)
    * [I want to manage a Connector or Realm that already exists](#i-want-to-manage-a-connector-or-realm-that-already-exists)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
    * [Defined types](#defined-types)
    * [Parameters](#parameters)
        * [tomcat](#tomcat-1)
        * [tomcat::config::properties::property](#tomcatconfigpropertiesproperty)
        * [tomcat::config::server](#tomcatconfigserver)
        * [tomcat::config::server::connector](#tomcatconfigserverconnector)
        * [tomcat::config::server::context](#tomcatconfigservercontext)
        * [tomcat::config::server::engine](#tomcatconfigserverengine)
        * [tomcat::config::server::globalnamingresource](#tomcatconfigserverglobalnamingresource)
        * [tomcat::config::server::host](#tomcatconfigserverhost)
        * [tomcat::config::server::listener](#tomcatconfigserverlistener)
        * [tomcat::config::server::realm](#tomcatconfigserverrealm)
        * [tomcat::config::server::service](#tomcatconfigserverservice)
        * [tomcat::config::server::tomcat_users](#tomcatconfigservertomcat_users)
        * [tomcat::config::server::valve](#tomcatconfigservervalve)
        * [tomcat::config::context](#tomcatconfigcontext)
        * [tomcat::config::context::environment](#tomcatconfigcontextenvironment)
        * [tomcat::config::context::manager](#tomcatconfigcontextmanager)
        * [tomcat::config::context::resource](#tomcatconfigcontextresource)
        * [tomcat::config::context::resourcelink](#tomcatconfigcontextresourcelink)
        * [tomcat::install](#tomcatinstall)
        * [tomcat::instance](#tomcatinstance)
        * [tomcat::service](#tomcatservice)
        * [tomcat::setenv::entry](#tomcatsetenventry)
        * [tomcat::war](#tomcatwar)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

## Overview

The tomcat module lets you use Puppet to install, deploy, and configure Tomcat web services.

## Module Description

Tomcat is a Java web service provider. The tomcat module lets you use Puppet to install Tomcat, manage its configuration file, and deploy web apps to it. It supports multiple instances of Tomcat spanning multiple versions.

## Setup

### Requirements

The tomcat module requires [puppetlabs-stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) version 4.0 or newer. On Puppet Enterprise you must meet this requirement before installing the module. To update stdlib, run:

```bash
puppet module upgrade puppetlabs-stdlib
```

### Beginning with tomcat

The simplest way to get Tomcat up and running with the tomcat module is to install the Tomcat source and start the service:

```puppet
tomcat::install { '/opt/tomcat':
  source_url => 'https://www-us.apache.org/dist/tomcat/tomcat-7/v7.0.x/bin/apache-tomcat-7.0.x.tar.gz',
}
tomcat::instance { 'default':
  catalina_home => '/opt/tomcat',
}
```

> Note: look up the correct version you want to install on the [version list](http://tomcat.apache.org/whichversion.html).

## Usage

### I want to run multiple instances of multiple versions of Tomcat

```puppet
class { 'java': }

tomcat::install { '/opt/tomcat8':
  source_url => 'https://www.apache.org/dist/tomcat/tomcat-8/v8.0.x/bin/apache-tomcat-8.0.x.tar.gz'
}
tomcat::instance { 'tomcat8-first':
  catalina_home => '/opt/tomcat8',
  catalina_base => '/opt/tomcat8/first',
}
tomcat::instance { 'tomcat8-second':
  catalina_home => '/opt/tomcat8',
  catalina_base => '/opt/tomcat8/second',
}
# Change the default port of the second instance server and HTTP connector
tomcat::config::server { 'tomcat8-second':
  catalina_base => '/opt/tomcat8/second',
  port          => '8006',
}
tomcat::config::server::connector { 'tomcat8-second-http':
  catalina_base         => '/opt/tomcat8/second',
  port                  => '8081',
  protocol              => 'HTTP/1.1',
  additional_attributes => {
    'redirectPort' => '8443'
  },
}

tomcat::install { '/opt/tomcat6':
  source_url => 'http://www-eu.apache.org/dist/tomcat/tomcat-6/v6.0.x/bin/apache-tomcat-6.0.x.tar.gz',
}
tomcat::instance { 'tomcat6':
  catalina_home => '/opt/tomcat6',
}
# Change tomcat 6's server and HTTP/AJP connectors
tomcat::config::server { 'tomcat6':
  catalina_base => '/opt/tomcat6',
  port          => '8105',
}
tomcat::config::server::connector { 'tomcat6-http':
  catalina_base         => '/opt/tomcat6',
  port                  => '8180',
  protocol              => 'HTTP/1.1',
  additional_attributes => {
    'redirectPort' => '8543'
  },
}
tomcat::config::server::connector { 'tomcat6-ajp':
  catalina_base         => '/opt/tomcat6',
  port                  => '8109',
  protocol              => 'AJP/1.3',
  additional_attributes => {
    'redirectPort' => '8543'
  },
}
```

> Note: look up the correct version you want to install on the [version list](http://tomcat.apache.org/whichversion.html).

### I want to deploy WAR files

Add the following to any existing installation with your own war source:
```puppet
tomcat::war { 'sample.war':
  catalina_base => '/opt/tomcat8/first',
  war_source    => '/opt/tomcat8/webapps/docs/appdev/sample/sample.war',
}
```

The name of the WAR file must end with `.war`.

The `war_source` can be a local path or a `puppet:///`, `http://`, or `ftp://` URL.

### I want to remove some configuration

Different configuration defined types will allow an ensure parameter to be passed, though the name may vary based on the defined type.

To remove a connector, for instance, the following configuration ensure that it is absent:

```puppet
tomcat::config::server::connector { 'tomcat8-jsvc':
  connector_ensure => 'absent',
  catalina_base    => '/opt/tomcat8/first',
  port             => '8080',
  protocol         => 'HTTP/1.1',
}
```

### I want to manage a Connector or Realm that already exists

Describe the Realm or HTTP Connector element using `tomcat::config::server::realm` or `tomcat::config::server::connector`, and set `purge_realms` or `purge_connectors` to `true`.

```puppet
tomcat::config::server::realm { 'org.apache.catalina.realm.LockOutRealm':
  realm_ensure => 'present',
  purge_realms => true,
}
```

Puppet removes any existing Connectors or Realms and leaves only the ones you've specified.

## Reference

### Classes

#### Public Classes

* `tomcat`: Main class. Manages some of the defaults for installing and configuring Tomcat.

#### Private Classes

* `tomcat::params`: Manages Tomcat parameters.

### Defined Types

#### Public Defined Types

* `tomcat::config::properties::property`: Adds a property to catalina.properties file
* `tomcat::config::server`: Configures attributes for the [Server element](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html) in `$CATALINA_BASE/conf/server.xml`.
* `tomcat::config::server::connector`: Configures [Connector elements](http://tomcat.apache.org/tomcat-8.0-doc/connectors.html) in `$CATALINA_BASE/conf/server.xml`.
* `tomcat::config::server::context`: Configures [Context elements](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html) in `$CATALINA_BASE/conf/server.xml`.
* `tomcat::config::server::engine`: Configures [Engine elements](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Introduction) in `$CATALINA_BASE/conf/server.xml`.
* `tomcat::config::server::globalnamingresource`: Configures [Global Resource elements](http://tomcat.apache.org/tomcat-8.0-doc/config/globalresources.html)
* `tomcat::config::server::host`: Configures [Host elements](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html) in `$CATALINA_BASE/conf/server.xml`.
* `tomcat::config::server::listener`: Configures [Listener elements](http://tomcat.apache.org/tomcat-8.0-doc/config/listeners.html) in `$CATALINA_BASE/conf/server.xml`.
* `tomcat::config::server::realm`: Configures [Realm elements](http://tomcat.apache.org/tomcat-8.0-doc/config/realm.html) in `$CATALINA_BASE/conf/server.xml`.
* `tomcat::config::server::service`: Configures a [Service element](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html) element nested in the `Server` element in `$CATALINA_BASE/conf/server.xml`.
* `tomcat::config::server::tomcat_users`: Configures user and role elements for [UserDatabaseRealm] (http://tomcat.apache.org/tomcat-8.0-doc/realm-howto.html#UserDatabaseRealm) or [MemoryRealm] (http://tomcat.apache.org/tomcat-8.0-doc/realm-howto.html#MemoryRealm) in `$CATALINA_BASE/conf/tomcat-users.xml` or any other specified file.
* `tomcat::config::server::valve`: Configures a [Valve](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html) element in `$CATALINA_BASE/conf/server.xml`.
* `tomcat::config::context`: Configures a [Context](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html) element in `$CATALINA_BASE/conf/context.xml`.
* `tomcat::config::context::manager`: Configures a [Manager](https://tomcat.apache.org/tomcat-8.0-doc/config/manager.html) element in `$CATALINA_BASE/conf/context.xml.
* `tomcat::config::context::environment`: Configures a [Environment](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Environment_Entries) element in `$CATALINA_BASE/conf/context.xml`.
* `tomcat::config::context::resource`: Configures a [Resource](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Resource_Definitions) element in `$CATALINA_BASE/conf/context.xml`.
* `tomcat::config::context::resourcelink`: Configures a [ResourceLink](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Resource_Links) element in `$CATALINA_BASE/conf/context.xml`.
* `tomcat::install`: Installs a Tomcat instance.
* `tomcat::instance`: Configures a Tomcat instance.
* `tomcat::service`: Provides Tomcat service management.
* `tomcat::setenv::entry`: Adds an entry to a Tomcat configuration file (e.g., `setenv.sh` or `/etc/sysconfig/tomcat`).
* `tomcat::war`:  Manages the deployment of WAR files.

#### Private defined types

* `tomcat::install::package`: Installs Tomcat from a package.
* `tomcat::install::source`: Installs Tomcat from source.
* `tomcat::instance::copy_from_home`: Copies required files from installation to instance
* `tomcat::instance::dependencies`: Declares puppet dependency chain for an instance.
* `tomcat::config::properties`: Creates instance catalina.properties

### Parameters

All parameters are optional except where otherwise noted.

#### tomcat
The base class sets defaults used by other defined types, such as `tomcat::install` and `tomcat::instance`, such as a default `catalina_home`.

##### `catalina_home`

Specifies the default root directory of the Tomcat installation.

Valid options: a string containing an absolute path.

Default value: '/opt/apache-tomcat'.

##### `group`

Specifies a default group to run Tomcat as.

Valid options: a string containing a valid group name.

Default value: 'tomcat'.

##### `install_from_source`

Specifies whether to default to installing Tomcat from source.

Valid options: `true` and `false`.

Default value: `true`.

##### `manage_group`

Determines whether defined types should default to creating the specified group, if it doesn't exist. Uses Puppet's native [`group` resource type](https://docs.puppetlabs.com/references/latest/type.html#group) with default parameters.

Valid options: `true` and `false`.

Default value: `true`.

##### `manage_user`

Determines whether defined types should default to creating the specified user, if it doesn't exist. Uses Puppet's native [`user` resource type](https://docs.puppetlabs.com/references/latest/type.html#user) with default parameters.

Valid options: `true` and `false`.

Default value: `true`.

##### `manage_base`
Specifies the default value of `manage_base` for all `tomcat::install` instances.

Default value: `true`.

##### `manage_home`
Specifies the default value of `manage_home` for all `tomcat::instance` instances.

Default value: `true`.

##### `manage_properties`
Specifies the default value of `manage_properties` for all `tomcat::instance` instances.

Default value: `true`.

##### `purge_connectors`

Specifies whether to purge any unmanaged Connector elements that match defined protocol but have a different port from the configuration file by default.

Valid options: `true` and `false`.

Default value: `false`.

##### `purge_realms`

Specifies whether to purge any unmanaged realm elements from the configuration file by default.

Valid options: `true` and `false`.

Default value: `false`.  If two realms are defined for a specific server config only use `purge_realms` for the first realm and ensure the realms enforce a strict order between each other.

##### `user`

Specifies a default user to run Tomcat as.

Valid options: a string containing a valid username.

Default value: 'tomcat'.

#### tomcat::config::properties::property

Specifies an additional entry for the catalina.properties file a given catalina base.

##### `property`

The name of the property.

Default value: `$name`.

##### `catalina_base`

The catalina base of the catalina.properties file. The resource will manage the values in `${catalina_base}/conf/catalina.properties` .

Required

##### `value`
The value of the property.

Required

#### tomcat::config::server

##### `address`

Specifies a TCP/IP address on which to listen for the shutdown command. Maps to the [address XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes).

Valid options: a string.

Default value: `undef`.

##### `address_ensure`

Specifies whether the [address XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes) should exist in the configuration file.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `catalina_base`

Specifies the base directory of the Tomcat installation to manage.

Valid options: a string containing an absolute path.

Default value: '$tomcat::catalina_home'.

##### `class_name`

Specifies the Java class name of a server implementation to use. Maps to the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes) in the configuration file.

Valid options: a string containing a Java class name.

Default value: `undef`.

##### `class_name_ensure`

Specifies whether the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes) should exist in the configuration file.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `port`

Specifies a port on which to listen for the designated shutdown command. Maps to the [port XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes).

Valid options: a string containing a port number.

Default value: `undef`.

##### `server_config`

Specifies a server.xml file to manage.

Valid options: a string containing an absolute path.

Default value: '${catalina_base}/config/server.xml'.

##### `shutdown`

Designates a command that shuts down Tomcat when the command is received through the specified address and port. Maps to the [shutdown XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/server.html#Common_Attributes).

Valid options: a string.

Default value: `undef`.

#### tomcat::config::server::connector

##### `additional_attributes`

Specifies any further attributes to add to the Connector.

Valid options: a hash of '< attribute >' => '< value >' pairs.

Default value: `{}`.

##### `attributes_to_remove`

Specifies any attributes to remove from the Connector.

Valid options: a hash of '< attribute >' => '< value >' pairs.

Default value: `[]`.

##### `catalina_base`

Specifies the base directory of the Tomcat installation to manage.

Valid options: a string containing an absolute path.

Default value: '$::tomcat/catalina_home'.

##### `connector_ensure`

Specifies whether the [Connector XML element](http://tomcat.apache.org/tomcat-8.0-doc/connectors.html) should exist in the configuration file.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `parent_service`

Specifies which Service element the Connector should nest under.

Valid options: a string containing the name attribute of the Service.

Default value: 'Catalina'.

##### `port`

*Required if `connector_ensure` is set to `true` or 'present'.* Sets a TCP port on which to create a server socket. Maps to the [port XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html#Common_Attributes).

Valid options: a string.

##### `protocol`

Specifies a protocol to use for handling incoming traffic. Maps to the [protocol XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html#Common_Attributes).

Valid options: a string.

Default value: `$name`.

##### `purge_connectors`

Specifies whether to purge any unmanaged Connector elements that match defined protocol but have a different port from the configuration file.

Valid options: `true` and `false`.

Default value: `false`.

##### `server_config`

Specifies a server.xml file to manage.

Valid options: a string containing an absolute path.

Default value: '${catalina_base}/config/server.xml'.

#### tomcat::config::server::context

##### `additional_attributes`

Specifies any further attributes to add to the Context.

Valid options: a hash of '< attribute >' => '< value >' pairs.

Default value: `{}`.

##### `attributes_to_remove`

Specifies any attributes to remove from the Context. 

Valid options: a hash of '< attribute >' => '< value >' pairs.

Default value: `[]`.

##### `catalina_base`

Specifies the base directory of the Tomcat installation to manage.

Valid options: a string containing an absolute path.

Default value: '$::tomcat/catalina_home'.

##### `context_ensure`

Specifies whether the [Context XML element](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html) should exist in the configuration file.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `doc_base`

Specifies a Document Base (or Context Root) directory or archive file. Maps to the [docBase XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Common_Attributes).

Valid options: a string containing a path (either an absolute path or a path relative to the appBase directory of the owning Host).

Default value: `$name`.

##### `parent_engine`

Specifies which Engine element the Context should nest under. Only valid if `parent_host` is specified.

Valid options: a string containing the name attribute of the Engine.

Default value: `undef`.

##### `parent_host`

Specifies which Host element the Context should nest under.

Valid options: a string containing the name attribute of the Host.

Default value: `undef`.

##### `parent_service`

Specifies which Service XML element the Context should nest under.

Valid options: a string containing the name attribute of the Service.

Default value: 'Catalina'.

##### `server_config`

Specifies a server.xml file to manage.

Valid options: a string containing an absolute path.

Default value: '${catalina_base}/config/server.xml'.

#### tomcat::config::server::engine

##### `background_processor_delay`

Determines the delay between invoking the backgroundProcess method on this engine and its child containers. Maps to the [backgroundProcessorDelay XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes).

Valid options: an integer, in seconds.

Default value: `undef`.

##### `background_processor_delay_ensure`

Specifies whether the [backgroundProcessorDelay XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) should exist in the configuration file.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `catalina_base`

Specifies the base directory of the Tomcat installation to manage.

Valid options: a string containing an absolute path.

Default value: '$::tomcat::catalina_home'.

##### `class_name`

Specifies the Java class name of a server implementation to use. Maps to the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes).

Valid options: a string containing a Java class name.

Default value: `undef`.

##### `class_name_ensure`

Specifies whether the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) should exist in the configuration file.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `default_host`

*Required.* Specifies a host to handle any requests directed to hostnames that exist on the server but are not defined in this configuration file. Maps to the [defaultHost XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) of the Engine.

Valid options: a string containing a hostname.

##### `engine_name`

Specifies the logical name of the Engine, used in log and error messages. Maps to the [name XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes).

Valid options: a string.

Default value: the `name` passed in your defined type.

##### `jvm_route`

Specifies an identifier to enable session affinity in load balancing. Maps to the [jvmRoute XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes).

Valid options: string.

Default value: `undef`.

##### `jvm_route_ensure`

Specifies whether the [jvmRoute XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) should exist in the configuration file.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `parent_service`

Specifies which Service element the Engine should nest under.

Valid options: a string containing the name attribute of the Service.

Default value: 'Catalina'.

##### `server_config`

Specifies a server.xml file to manage.

Valid options: a string containing an absolute path.

Default value: '${catalina_base}/config/server.xml'.

##### `start_stop_threads`

Sets how many threads the Engine should use to start child Host elements in parallel. Maps to the [startStopThreads XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes).

Valid options: a string.

Default value: `undef`.

##### `start_stop_threads_ensure`

Specifies whether the [startStopThreads XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/engine.html#Common_Attributes) should exist in the configuration file.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

#### tomcat::config::server::globalnamingresource

Configure GlobalNamingResources Resource elements in '$CATALINA_BASE/conf/server.xml'

##### `ensure`

Determines whether the specified XML element should exist in the configuration file.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `resource_name`

Optionally override the globalnamingresource name that is normally taken from the Puppet resource's `$name`.

##### `catalina_base`

Specifies the base directory of the Tomcat instance.

Valid options: a string containing an absolute path.

Default value: '$::tomcat::catalina_home'.

##### `type`

Specifies the type of element to create

Valid options: `Resource`, `Environment` or any other valid node.

Default value: `Resource`.

>Note: This is used verbatim in your configuration so make sure the case is correct.

##### `additional_attributes`

Specifies any further attributes to add to the Host.

Valid options: a hash of '< attribute >' => '< value >' pairs.

Default value: `{}`.

##### `attributes_to_remove`

Specifies any attributes to remove from the Host.

Valid options: an array of `'< attribute >' => '< value >'` pairs.

Default value: `[]`.

##### `server_config`

Specifies a server.xml file to manage.

Valid options: a string containing an absolute path.

Default value: '${catalina_base}/config/server.xml'.

#### tomcat::config::server::host

##### `additional_attributes`

Specifies any further attributes to add to the Host.

Valid options: a hash of '< attribute >' => '< value >' pairs.

Default value: `{}`.

##### `aliases`

Optional array that specifies the list of [Host Name Aliases](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Host_Name_Aliases) for this particular Host.  If omitted, any currently-defined Aliases will not be altered.  If present, the list Aliases  will be set to exactly match the contents of this array.  Thus, for example, an empty array can be used to explicitly force there to be no Aliases for the Host.

##### `app_base`

*Required unless [`host_ensure`](#host_ensure) is set to `false` or 'absent'.* Specifies the Application Base directory for the virtual host. Maps to the [appBase XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Common_Attributes).

Valid options: a string.

##### `attributes_to_remove`

Specifies any attributes to remove from the Host.

Valid options: an array of '< attribute >' => '< value >' pairs.

Default value: `[]`.

##### `catalina_base`

Specifies the base directory of the Tomcat installation to manage.

Valid options: a string containing an absolute path.

Default value: '$::tomcat::catalina_home'.

##### `host_ensure`

Specifies whether the virtual host (the [Host XML element](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Introduction)) should exist in the configuration file.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `host_name`

Specifies the network name of the virtual host, as registered on your DNS server. Maps to the [name XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/host.html#Common_Attributes). 

Valid options: a string.

Default value: the 'name' passed in your defined type.

##### `parent_service`

Specifies which Service element the Host should nest under. 

Valid options: a string containing the name attribute of the Service.

Default value: 'Catalina'.

##### `server_config`

Specifies a server.xml file to manage.

Valid options: a string containing an absolute path.

Default value: '${catalina_base}/config/server.xml'.

#### tomcat::config::server::listener

##### `additional_attributes`

Specifies any further attributes to add to the Listener.

Valid options: a hash of '< attribute >' => '< value >' pairs.

Default value: `{}`.

##### `attributes_to_remove`

Specifies any attributes to remove from the Listener.

Valid options: a hash of '< attribute >' => '< value >' pairs.

Default value: `[]`.

##### `catalina_base`

Specifies the base directory of the Tomcat installation.

Valid options: a string containing an absolute path.

Default value: '$::tomcat::catalina_home'.

##### `class_name`

Specifies the Java class name of a server implementation to use. Maps to the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/listeners.html#Common_Attributes) of a Listener Element.

Valid options: a string containing a Java class name.

Default value: `$name`.

##### `listener_ensure`

Specifies whether the [Listener XML element](http://tomcat.apache.org/tomcat-8.0-doc/config/listeners.html) should exist in the configuration file.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `parent_engine`

Specifies which Engine element this Listener should nest under. 

Valid options: a string containing the name attribute of the Engine.

Default value: `undef`.

##### `parent_host`

Specifies which Host element this Listener should nest under.

Valid options: a string containing the name attribute of the Host.

Default value: `undef`.

##### `parent_service`

Specifies which Service element the Listener should nest under. Only valid if `parent_engine` or `parent_host` is specified.

Valid options: a string containing the name attribute of the Service.

Default value: 'Catalina'.

##### `server_config`

Specifies a server.xml file to manage.

Valid options: a string containing an absolute path.

Default value: '${catalina_base}/config/server.xml'.

#### tomcat::config::server::realm

##### `additional_attributes`

Specifies any further attributes to add to the Realm element.

Valid options: a hash of '< attribute >' => '< value >' pairs.

Default value: `{}`.

##### `attributes_to_remove`

Specifies any attributes to remove from the Realm element.

Valid options: an array of '< attribute >' => '< value >' pairs.

Default value: `[]`.

##### `catalina_base`

Specifies the base directory of the Tomcat installation.

Default value: '$::tomcat::catalina_home'.

##### `class_name`

Specifies the Java class name of a Realm implementation to use. Maps to the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/realm.html#Common_Attributes).

Valid options: a string containing a Java class name.

Default value: the `name` passed in your defined type.

##### `parent_engine`

Specifies which Engine element this Realm should nest under.

Valid options: a string containing the name attribute of the Engine.

Default value: 'Catalina'.

##### `parent_host`

Specifies which Host element this Realm should nest under.

Valid options: a string containing the name attribute of the Host.

Default value: `undef`.

##### `parent_realm`

Specifies which Realm element this Realm should nest under.

Valid options: a string containing the className attribute of the Realm element.

Default value: `undef`.

##### `parent_service`

Specifies which Service element this Realm element should nest under.

Valid options: a string containing the name attribute of the Service.

Default value: 'Catalina'.

##### `purge_realms`

Specifies whether to purge any unmanaged Realm elements from the configuration file.

Valid options: `true` and `false`.

Default value: `false`.

##### `realm_ensure`

Specifies whether the Realm element should exist in the configuration file.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `server_config`

Specifies a server.xml file to manage.

Valid options: a string containing an absolute path.

Default value: '${catalina_base}/config/server.xml'.

#### tomcat::config::server::service

##### `catalina_base`

Specifies the base directory of the Tomcat installation.

Valid options: a string containing an absolute path.

Default value: '$::tomcat::catalina_home'.

##### `class_name`

Specifies the Java class name of a server implementation to use. Maps to the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html#Common_Attributes).

Valid options: a string containing a Java class name.

Default value: `undef`.

##### `class_name_ensure`

Specifies whether the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html#Common_Attributes) should exist in the configuration file.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `server_config`

Specifies a server.xml file to manage.

Valid options: a string containing an absolute path.

Default value: '${catalina_base}/config/server.xml'.

##### `service_ensure`

Specifies whether the [Service element](http://tomcat.apache.org/tomcat-8.0-doc/config/service.html#Introduction) should exist in the configuration file. 

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

#### tomcat::config::server::tomcat_users

##### `catalina_base`

Specifies the base directory of the Tomcat installation.

Valid options: a string containing an absolute path.

Default value: '$::tomcat::catalina_home'.

##### `element`

Specifies the type of element to manage.

Valid options: 'user' or 'role'.

Default value: `user`.

##### `element_name`

Sets the element's username (or rolename, if `element` is set to 'role').

Valid options: a string.

Default value: `$name`.

##### `ensure`

Determines whether the specified XML element should exist in the configuration file.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `file`

Specifies the configuration file to manage.

Valid options: a string containing a fully-qualified path.

Default value: '$CATALINA_BASE/conf/tomcat-users.xml'.

##### `group`

Specifies the group of the configuration file.

Default value: `$::tomcat::group`.

##### `manage_file`

Specifies whether to create the specified configuration file if it doesn't exist. Uses Puppet's native [`file` resource type](https://docs.puppetlabs.com/references/latest/type.html#file) with default parameters.

Valid options: `true` and `false`.

Default value: `true`.

##### `owner`

Specifies the owner of the configuration file.

Default value: `$::tomcat::user`.

##### `password`

Specifies a password for user elements.

Valid options: a string.

Default value: `undef`.

##### `roles`

Specifies one or more roles. Only valid if `element` is set to 'role' or 'user'.

Valid options: an array of strings.

Default value: `[]`.

#### tomcat::config::server::valve

##### `additional_attributes`

Specifies any further attributes to add to the Valve.

Valid options: a hash of '< attribute >' => '< value >' pairs.

Default value: `{}`.

##### `attributes_to_remove`

Specifies any attributes to remove from the Valve.

Valid options: a hash of '< attribute >' => '< value >' pairs.

Default value: `[]`.

##### `catalina_base`

Specifies the base directory of the Tomcat installation.

Valid options: a string containing an absolute path.

Default value: `$::tomcat::catalina_home`.

##### `class_name`

Specifies the Java class name of a server implementation to use. Maps to the [className XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Access_Logging/Attributes).

Valid options: a string containing a Java class name.

Default value: the 'name' passed in your defined type.

##### `parent_host`

Specifies which virtual host the Valve should nest under.

Valid options: a string containing the name of a Host element.

Default value: If you don't specify a host, the Valve element nests under the Engine of your specified parent Service.

##### `parent_service`

Specifies which Service element the Valve should nest under.

Valid options: a string containing the name of a Service element.

Default value: 'Catalina'.

##### `parent_context`

Specifies which Context element the Valve should nest under.

Valid options: a string containing the name of a Context element (matching the docbase attribute).

Default value: If you don't specify a context, the Valve element nests under either the Parent Host if defined or the Engine of your specified parent Service.

##### `server_config`

Specifies a server.xml file to manage.

Valid options: a string containing an absolute path.

Default value: '${catalina_base}/config/server.xml'.

##### `valve_ensure`

Specifies whether the Valve should exist in the configuration file. Maps to the  [Valve XML element](http://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#Introduction).

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

#### tomcat::config::context

Specifies a configuration Context element in `${catalina_base}/conf/context.xml` for other `tomcat::config::context::*` defined types.

##### `catalina_base`

Specifies the root of the Tomcat installation.

#### tomcat::config::context::manager
Specifies a Manager element in the designated xml configuration.

##### `ensure`

specifies whether you are trying to add or remove the Manager element.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `catalina_base`

Specifies the root of the Tomcat installation.

Default value: '$tomcat::catalina_home'.

##### `manager_classname`

The name of the Manager to be created.

Default value: `$name`.

##### `additional_attributes`

Specifies any additional attributes to add to the Manager.

Should be a hash of the format 'attribute' => 'value'.

Optional

##### `attributes_to_remove`

Specifies any attributes to remove from the Manager. 

Should be a hash of the format 'attribute' => 'value'.

Optional

#### tomcat::config::context::environment

Specifies Environment elements in `${catalina_base}/conf/context.xml`

##### `ensure`

Specifies whether you are trying to add or remove the Environment element

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `environment_name`

The name of the Environment Entry to be created, relative to the `java:comp/env` context.

Default value: `$name`.

##### `type`

The fully qualified Java class name expected by the web application for this environment entry.

Required to create the environment entry.

##### `value`

The value that will be presented to the application when requested from the JNDI context.

Required to create the environment entry.

##### `description`

The description is an an optional string for a human-readable description of this environment entry.

##### `override`

An optional string or boolean to specify if you do not want an `<env-entry>` for the same environment entry name to override the value specified here (set it to `false`).

By default, overrides are allowed.

##### `catalina_base`

Specifies the root of the Tomcat installation.

Default value: '$tomcat::catalina_home'.

##### `additional_attributes`

Specifies any additional attributes to add to the Environment.

Should be a hash of the format 'attribute' => 'value'.

Optional

##### `attributes_to_remove`

Specifies any attributes to remove from the Environment.

Should be a hash of the format 'attribute' => 'value'.

Optional

#### tomcat::config::context::resource
Specifies Resource elements in `${catalina_base}/conf/context.xml`

##### `ensure`

specifies whether you are trying to add or remove the Resource element. 

Valid options: `true`, `false`, 'present', 'absent'.

Defaults value: 'present'

##### `resource_name`

The name of the Resource to be created, relative to the `java:comp/env` context.

Default value: `$name`.

##### `resource_type`

The fully qualified Java class name expected by the web application when it performs a lookup for this resource. Required to create the resource.

##### `catalina_base`

Specifies the root of the Tomcat installation.

Default value: '$tomcat::catalina_home'.

##### `additional_attributes`

Specifies any additional attributes to add to the Valve.

Should be a hash of the format 'attribute' => 'value'. 

Optional

##### `attributes_to_remove`

Specifies any attributes to remove from the Valve.

Should be a hash of the format 'attribute' => 'value'.

Optional

#### tomcat::config::context::resourcelink

Specifies a ResourceLink element in the designated xml configuration.

##### `ensure`

specifies whether you are trying to add or remove the ResourceLink element.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `catalina_base`

Specifies the root of the Tomcat installation.

Default value: `$tomcat::catalina_home`.

##### `resourcelink_name`

The name of the ResourceLink to be created, relative to the `java:comp/env` context.

Default value: `$name`.

##### `resourcelink_type`

The fully qualified Java class name expected by the web application when it performs a lookup for this resource link.

##### `additional_attributes`

Specifies any additional attributes to add to the Valve.

Should be a hash of the format 'attribute' => 'value'.

Optional

##### `attributes_to_remove`

Specifies any attributes to remove from the Valve.

Should be a hash of the format 'attribute' => 'value'.

Optional

#### `tomcat::install`

Installs the software into the given directory from a source Apache Tomcat tarball. Alternatively, it may be used to install a tomcat package.

Tomcat instances may then be created from the install using `tomcat::instance` and pointing `tomcat::instance::catalina_home` to the directory managed by `tomcat::install`.

##### `catalina_home`

specifies the directory of the Tomcat installation from which the instance should be created.

Valid options: a string containing an absolute path.

Default value: '$::tomcat::catalina_home'.

##### `install_from_source`

Specifies whether to install from source or from a package. If set to `true` installation uses the `source_url`, `source_strip_first_dir`, `user`, `group`, `manage_user`, and `manage_group` parameters. If set to `false` installation uses the `package_ensure`, `package_name`, and `package_options` parameters.

Valid options: `true` and `false`.

Default value: `true`.

##### `source_url`

In single-instance mode: *Required if `install_from_source` is set to `true`.* Specifies the source URL to install from.

Valid options: a string containing a `puppet://`, `http(s)://`, or `ftp://` URL.

##### `source_strip_first_dir`

Specifies whether to strip the topmost directory of the tarball when unpacking it. Only valid if `install_from_source` is set to `true`.

Valid options: `true` and `false`.

Default value: `true`.

##### `environment`

Environment variables for settings such as http_proxy, https_proxy, or ftp_proxy. These are passed through to the staging module and then to the underlying exec(s), so it follows the same format of the exec type [`environment`](https://docs.puppet.com/puppet/latest/reference/type.html#exec-attribute-environment).

##### `user`

Specifies the owner of the source installation directory.

Default value: `$::tomcat::user`.

##### `group`

Specifies the group of the source installation directory.

Default value: `$::tomcat::group`.

##### `manage_user`

Specifies whether the user should be managed by this module or not.

Default value: `$::tomcat::manage_user`.

##### `manage_group`

Specifies whether the group should be managed by this module or not.

Default value: `$::tomcat::manage_group`.

##### `manage_home`

Specifies whether the directory of catalina_home should be managed by puppet. This may not be preferable in network filesystem environments.

Default value: `true`.

##### `package_ensure`

Determines whether the specified package should be installed. Only valid if `install_from_source` is set to `false`. Maps to the `ensure` parameter of Puppet's native [`package` resource type](https://docs.puppetlabs.com/references/latest/type.html#package).

Default value: 'present'.

##### `package_name`

*Required if `install_from_source` is set to `false`.* Specifies the package to install.

Valid options: a string containing a valid package name.

##### `package_options`

*Unused if `install_from_source` is set to `true`.* Specify additional options to use on the generated package resource. See the documentation of the [`package` resource type](https://docs.puppetlabs.com/references/latest/type.html#package-attribute-install_options) for possible values.

#### tomcat::instance

Declares a tomcat instance.

There are two different modes of use: a single tomcat installation and instance (called 'single-instance' by this readme), or a single tomcat installation   with multiple instances, each with its own directory structure (called 'multi-instance' by this readme).

- single-instance: If a `tomcat::instance` is declared with `catalina_home` and `catalina_base` both pointing to the directory of a `tomcat::install` then it only configures a single instance.
- multi-instance: If a `tomcat::instance` is declared with `catalina_home` pointing to the same directory as a `tomcat::install` and `catalina_base` pointing at a different directory then it is configured as an instance of the Apache Tomcat software. Multiple instances of a single install may be created using this method. A `tomcat::install` declaration should use a user and/or group such that `tomcat::instance` declarations can access the install.

##### `catalina_base`

Specifies the `$CATALINA_BASE` of the Tomcat instance where logs, configuration files, and the 'webapps' directory are managed. For single-instance installs, this is the same as the `catalina_home` parameter

Valid options: a string containing an absolute path.

Default value: `$catalina_home`.

##### `catalina_home`

Specifies the directory where the Apache Tomcat software is installed by a `tomcat::install` resource.

Valid options: a string containing an absolute path.

Default value: '$::tomcat::catalina_home'.

##### `user`

Specifies the owner of the instance directories and files.

Default value: `$::tomcat::user`.

##### `group`

Specifies the group of the instance directories and files.

Default value: `$::tomcat::group`.

##### `manage_user`

Specifies whether the user should be managed by this module or not.

Default value: `$::tomcat::manage_user`.

##### `manage_group`

Specifies whether the group should be managed by this module or not.

Default value: `$::tomcat::manage_group`.

##### `manage_base`

Specifies whether the directory of catalina_base should be managed by puppet. This may not be preferable in network filesystem environments.

Default value: `true`.

##### `manage_service`

Specifies whether a `tomcat::service` corresponding to this instance should be declared. 

Valid options: `true`, `false`

Default value: `true` (multi-instance installs), `false` ()single-instance installs).

##### `manage_properties`

Specifies whether the `catalina.properties` file is created and managed. If `true`, custom modifications to this file will be overwritten during runs

Valid options: `true`, `false`

Default value: `true`.

##### `java_home`

Specifies the java home to be used when declaring a `tomcat::service` instance. See [tomcat::service](# tomcatservice)

##### `use_jsvc`

Specifies whether jsvc should be used when declaring a `tomcat::service` instance.

>Note that this module will not compile and install jsvc for you. See [tomcat::service](# tomcatservice)

##### `use_init`

Specifies whether an init script should be managed when declaring a `tomcat::service` instance. See [tomcat::service](# tomcatservice)

#### tomcat::service

##### `catalina_base`

Specifies the base directory of the Tomcat installation.

Valid options: a string containing an absolute path.

Default value: '$::tomcat::catalina_home'.

##### `catalina_home`

Specifies the root directory of the Tomcat installation.

Valid options: a string containing an absolute path.

Default value: '$::tomcat::catalina_home'.

##### `java_home`

Specifies where Java is installed. Only applies if `use_jsvc` is set to `true`.

Valid options: a string containing an absolute path.

Default value: `undef`.

>Note: if you don't specify a home path in this parameter, Puppet does not pass the `-home` switch to Tomcat. That can cause problems on some systems, so we recommend including this parameter.

##### `service_enable`

Specifies whether to enable the Tomcat service at boot. Only valid if `use_init` is set to `true`.

Valid options: `true` and `false`.

Default value: `true`, if `use_init` is set to `true` and `service_ensure` is set to 'running' or `true`.

##### `service_ensure`

Specifies whether the Tomcat service should be running. Maps to the `ensure` parameter of Puppet's native [`service` resource type](https://docs.puppetlabs.com/references/latest/type.html#service).

Valid options: 'running', 'stopped', `true`, and `false`.

Default value: 'present'.

##### `service_name`

*Required if `use_init` is set to `true`.* Specifies the name of the Tomcat service.

Valid options: a string.

##### `start_command`

Designates a command to start the service.

Valid options: a string.

Default value: determined by the values of `use_init` and `use_jsvc`.

##### `stop_command`

Designates a command to stop the service.

Valid options: a string.

Default value: determined by the values of `use_init` and `use_jsvc`.

##### `use_init`

Specifies whether to use a package-provided init script for service management.

 * `$CATALINA_HOME/bin/catalina.sh start`
 * `$CATALINA_HOME/bin/catalina.sh stop`

Valid options: `true` and `false`.

Default value: `false`.

>Note that the tomcat module does not supply an init script. If both `use_jsvc` and `use_init` are set to `false`, tomcat uses the following commands for service management:

##### `use_jsvc`

Specifies whether to use Jsvc for service management. If both `use_jsvc` and `use_init` are set to `false`, tomcat uses the following commands for service management:

 * `$CATALINA_HOME/bin/catalina.sh start`
 * `$CATALINA_HOME/bin/catalina.sh stop`

Valid options: `true` and `false`.

Default value: `false`.

##### `user`

The user of the jsvc process when `use_init => true`

#### tomcat::setenv::entry

##### `base_path`

**Deprecated.** Please use `config_file` instead.

##### `config_file`

Specifies the configuration file to edit.

Valid options: a string containing an absolute path.

Default value: '$::tomcat::catalina_home/bin/setenv.sh.

##### `ensure`

Determines whether the fragment should exist in the configuration file.

Valid options: 'present', 'absent'.

Default value: 'present'.

##### `group`

Specifies the group of the config file.

Default value: `$::tomcat::group`.

##### `order`

Determines the ordering of your parameters in the configuration file (parameters with lower `order` values appear first.)

Valid options: an integer or a string containing an integer.

Default value: `10`.

###### `addto`

Defines an additional environment variable that will be added to the beginning of the `param`

##### `param`

Specifies a parameter to manage.

Valid options: a string.

Default value: the `name` passed in your defined type.

##### `quote_char`

Specifies a character to include before and after the specified value.

Valid options: a string (usually a single or double quote).

Default value: (blank).

##### `user`

Specifies the owner of the config file.

Default value: `$::tomcat::user`.

##### `value`

*Required.* Provides the value(s) of the managed parameter.

Valid options: a string or an array. If passing an array, separate values with a single space.

##### `doexport`

Specifies if you want to append export to the entry.

Valid options: `true` or `false`

Default value: `true`.

#### `tomcat::war`

##### `app_base`

Specifies where to deploy the WAR. Cannot be used in combination with `deployment_path`.

Valid options: a string containing a path relative to `$CATALINA_BASE`.

Default value: If you don't specify an `app_base`, Puppet deploys the WAR to your specified `deployment_path`. If you don't specify that either, the WAR deploys to `${catalina_base}/webapps`.

##### `catalina_base`

Specifies the base directory of the Tomcat installation.

Valid options: a string containing an absolute path.

Default value: `$::tomcat::catalina_home`.

##### `deployment_path`

Specifies where to deploy the WAR. Cannot be used in combination with `app_base`.

Valid options: a string containing an absolute path.

Default value: If you don't specify a `deployment_path`, Puppet deploys the WAR to your specified `app_base`. If you don't specify that either, the WAR deploys to `${catalina_base}/webapps`.

##### `war_ensure`

Specifies whether the WAR should exist.

Valid options: `true`, `false`, 'present', and 'absent'.

Default value: 'present'.

##### `war_name`

Specifies the name of the WAR.

Valid options: a string containing a filename that ends in '.war'.

Default value: the `name` passed in your defined type.

##### `war_purge`

Specifies whether to purge the exploded WAR directory. Only applicable when `war_ensure` is set to 'absent' or `false`.

Valid options: `true` and `false`.

Default value: `true`.

>Note: Setting this parameter to `false` does not prevent Tomcat from removing the exploded WAR directory if Tomcat is running and autoDeploy is set to `true`.

##### `war_source`

*Required unless `war_ensure` is set to `false` or 'absent'.* Specifies the source to deploy the WAR from.

Valid options: a string containing a `puppet://`, `http(s)://`, or `ftp://` URL.

## Limitations

This module only supports Tomcat installations on Unix-like systems.  The `tomcat::config::server*` defined types require Augeas version 1.0.0 or newer.

### Multiple Instances

Some Tomcat packages do not let you install more than one instance. You can avoid this limitation by installing Tomcat from source.

## Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

For more information, see our [module contribution guide.](https://docs.puppetlabs.com/forge/contributing.html)

### Contributors

To see who's already involved, see the [list of contributors.](https://github.com/puppetlabs/puppetlabs-tomcat/graphs/contributors)

### Running tests

This project contains tests for both [rspec-puppet](http://rspec-puppet.com/) and [beaker-rspec](https://github.com/puppetlabs/beaker-rspec) to verify functionality. For in-depth information, please see their respective documentation.

Quickstart:

```bash
gem install bundler
bundle install
bundle exec rake spec
bundle exec rspec spec/acceptance
RS_DEBUG=yes bundle exec rspec spec/acceptance
```
