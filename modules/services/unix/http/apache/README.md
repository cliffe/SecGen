# apache

[Module description]: #module-description

[Setup]: #setup
[Beginning with Apache]: #beginning-with-apache

[Usage]: #usage
[Configuring virtual hosts]: #configuring-virtual-hosts
[Configuring virtual hosts with SSL]: #configuring-virtual-hosts-with-ssl
[Configuring virtual host port and address bindings]: #configuring-virtual-host-port-and-address-bindings
[Configuring virtual hosts for apps and processors]: #configuring-virtual-hosts-for-apps-and-processors
[Configuring IP-based virtual hosts]: #configuring-ip-based-virtual-hosts
[Installing Apache modules]: #installing-apache-modules
[Installing arbitrary modules]: #installing-arbitrary-modules
[Installing specific modules]: #installing-specific-modules
[Configuring FastCGI servers]: #configuring-fastcgi-servers-to-handle-php-files
[Load balancing examples]: #load-balancing-examples
[apache affects]: #what-the-apache-module-affects

[Reference]: #reference
[Public classes]: #public-classes
[Private classes]: #private-classes
[Public defined types]: #public-defined-types
[Private defined types]: #private-defined-types
[Templates]: #templates

[Limitations]: #limitations

[Development]: #development
[Contributing]: #contributing
[Testing]: #testing

[`AddDefaultCharset`]: https://httpd.apache.org/docs/current/mod/core.html#adddefaultcharset
[`add_listen`]: #add_listen
[`Alias`]: https://httpd.apache.org/docs/current/mod/mod_alias.html#alias
[`AliasMatch`]: https://httpd.apache.org/docs/current/mod/mod_alias.html#aliasmatch
[aliased servers]: https://httpd.apache.org/docs/current/urlmapping.html
[`AllowEncodedSlashes`]: https://httpd.apache.org/docs/current/mod/core.html#allowencodedslashes
[`apache`]: #class-apache
[`apache_version`]: #apache_version
[`apache::balancer`]: #defined-type-apachebalancer
[`apache::balancermember`]: #defined-type-apachebalancermember
[`apache::fastcgi::server`]: #defined-type-apachefastcgiserver
[`apache::mod`]: #defined-type-apachemod
[`apache::mod::<MODULE NAME>`]: #classes-apachemodmodule-name
[`apache::mod::alias`]: #class-apachemodalias
[`apache::mod::auth_cas`]: #class-apachemodauth_cas
[`apache::mod::auth_mellon`]: #class-apachemodauth_mellon
[`apache::mod::authn_dbd`]: #class-apachemodauthn_dbd
[`apache::mod::authnz_ldap`]: #class-apachemodauthnz_ldap
[`apache::mod::cluster`]: #class-apachemodcluster
[`apache::mod::disk_cache`]: #class-apachemoddisk_cache
[`apache::mod::dumpio`]: #class-apachemoddumpio
[`apache::mod::event`]: #class-apachemodevent
[`apache::mod::ext_filter`]: #class-apachemodext_filter
[`apache::mod::geoip`]: #class-apachemodgeoip
[`apache::mod::itk`]: #class-apachemoditk
[`apache::mod::ldap`]: #class-apachemodldap
[`apache::mod::passenger`]: #class-apachemodpassenger
[`apache::mod::peruser`]: #class-apachemodperuser
[`apache::mod::prefork`]: #class-apachemodprefork
[`apache::mod::proxy`]: #class-apachemodproxy
[`apache::mod::proxy_balancer`]: #class-apachemodproxybalancer
[`apache::mod::proxy_fcgi`]: #class-apachemodproxy_fcgi
[`apache::mod::proxy_html`]: #class-apachemodproxy_html
[`apache::mod::security`]: #class-apachemodsecurity
[`apache::mod::shib`]: #class-apachemodshib
[`apache::mod::ssl`]: #class-apachemodssl
[`apache::mod::status`]: #class-apachemodstatus
[`apache::mod::worker`]: #class-apachemodworker
[`apache::mod::wsgi`]: #class-apachemodwsgi
[`apache::params`]: #class-apacheparams
[`apache::version`]: #class-apacheversion
[`apache::vhost`]: #defined-type-apachevhost
[`apache::vhost::custom`]: #defined-type-apachevhostcustom
[`apache::vhost::WSGIImportScript`]: #wsgiimportscript
[Apache HTTP Server]: https://httpd.apache.org
[Apache modules]: https://httpd.apache.org/docs/current/mod/
[array]: https://docs.puppet.com/puppet/latest/reference/lang_data_array.html

[audit log]: https://github.com/SpiderLabs/ModSecurity/wiki/ModSecurity-2-Data-Formats#audit-log

[beaker-rspec]: https://github.com/puppetlabs/beaker-rspec

[certificate revocation list]: https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslcarevocationfile
[certificate revocation list path]: https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslcarevocationpath
[common gateway interface]: https://httpd.apache.org/docs/current/howto/cgi.html
[`confd_dir`]: #confd_dir
[`content`]: #content
[custom error documents]: https://httpd.apache.org/docs/current/custom-error.html
[`custom_fragment`]: #custom_fragment

[`default_mods`]: #default_mods
[`default_ssl_crl`]: #default_ssl_crl
[`default_ssl_crl_path`]: #default_ssl_crl_path
[`default_ssl_vhost`]: #default_ssl_vhost
[`dev_packages`]: #dev_packages
[`directory`]: #directory
[`directories`]: #parameter-directories-for-apachevhost
[`DirectoryIndex`]: https://httpd.apache.org/docs/current/mod/mod_dir.html#directoryindex
[`docroot`]: #docroot
[`docroot_owner`]: #docroot_owner
[`docroot_group`]: #docroot_group
[`DocumentRoot`]: https://httpd.apache.org/docs/current/mod/core.html#documentroot

[`EnableSendfile`]: https://httpd.apache.org/docs/current/mod/core.html#enablesendfile
[enforcing mode]: http://selinuxproject.org/page/Guide/Mode
[`ensure`]: https://docs.puppet.com/latest/type.html#package-attribute-ensure
[`error_log_file`]: #error_log_file
[`error_log_syslog`]: #error_log_syslog
[`error_log_pipe`]: #error_log_pipe
[`ExpiresByType`]: https://httpd.apache.org/docs/current/mod/mod_expires.html#expiresbytype
[exported resources]: http://docs.puppet.com/latest/reference/lang_exported.md
[`ExtendedStatus`]: https://httpd.apache.org/docs/current/mod/core.html#extendedstatus

[Facter]: http://docs.puppet.com/facter/
[FastCGI]: http://www.fastcgi.com/
[FallbackResource]: https://httpd.apache.org/docs/current/mod/mod_dir.html#fallbackresource
[`fallbackresource`]: #fallbackresource
[`FileETag`]: https://httpd.apache.org/docs/current/mod/core.html#fileetag
[filter rules]: https://httpd.apache.org/docs/current/filter.html
[`filters`]: #filters
[`ForceType`]: https://httpd.apache.org/docs/current/mod/core.html#forcetype

[GeoIPScanProxyHeaders]: http://dev.maxmind.com/geoip/legacy/mod_geoip2/#Proxy-Related_Directives
[`gentoo/puppet-portage`]: https://github.com/gentoo/puppet-portage

[Hash]: https://docs.puppet.com/puppet/latest/reference/lang_data_hash.html
[`HttpProtocolOptions`]: http://httpd.apache.org/docs/current/mod/core.html#httpprotocoloptions

[`IncludeOptional`]: https://httpd.apache.org/docs/current/mod/core.html#includeoptional
[`Include`]: https://httpd.apache.org/docs/current/mod/core.html#include
[interval syntax]: https://httpd.apache.org/docs/current/mod/mod_expires.html#AltSyn
[`ip`]: #ip
[`ip_based`]: #ip_based
[IP-based virtual hosts]: https://httpd.apache.org/docs/current/vhosts/ip-based.html

[`KeepAlive`]: https://httpd.apache.org/docs/current/mod/core.html#keepalive
[`KeepAliveTimeout`]: https://httpd.apache.org/docs/current/mod/core.html#keepalivetimeout
[`keepalive` parameter]: #keepalive
[`keepalive_timeout`]: #keepalive_timeout
[`limitreqfieldsize`]: https://httpd.apache.org/docs/current/mod/core.html#limitrequestfieldsize

[`lib`]: #lib
[`lib_path`]: #lib_path
[`Listen`]: https://httpd.apache.org/docs/current/bind.html
[`ListenBackLog`]: https://httpd.apache.org/docs/current/mod/mpm_common.html#listenbacklog
[`LoadFile`]: https://httpd.apache.org/docs/current/mod/mod_so.html#loadfile
[`LogFormat`]: https://httpd.apache.org/docs/current/mod/mod_log_config.html#logformat
[`logroot`]: #logroot
[Log security]: https://httpd.apache.org/docs/current/logs.html#security

[`manage_docroot`]: #manage_docroot
[`manage_user`]: #manage_user
[`manage_group`]: #manage_group
[`supplementary_groups`]: #supplementary_groups
[`MaxConnectionsPerChild`]: https://httpd.apache.org/docs/current/mod/mpm_common.html#maxconnectionsperchild
[`max_keepalive_requests`]: #max_keepalive_requests
[`MaxRequestWorkers`]: https://httpd.apache.org/docs/current/mod/mpm_common.html#maxrequestworkers
[`MaxSpareThreads`]: https://httpd.apache.org/docs/current/mod/mpm_common.html#maxsparethreads
[MIME `content-type`]: https://www.iana.org/assignments/media-types/media-types.xhtml
[`MinSpareThreads`]: https://httpd.apache.org/docs/current/mod/mpm_common.html#minsparethreads
[`mod_alias`]: https://httpd.apache.org/docs/current/mod/mod_alias.html
[`mod_auth_cas`]: https://github.com/Jasig/mod_auth_cas
[`mod_auth_kerb`]: http://modauthkerb.sourceforge.net/configure.html
[`mod_authnz_external`]: https://github.com/phokz/mod-auth-external
[`mod_auth_dbd`]: http://httpd.apache.org/docs/current/mod/mod_authn_dbd.html
[`mod_auth_mellon`]: https://github.com/UNINETT/mod_auth_mellon
[`mod_dbd`]: http://httpd.apache.org/docs/current/mod/mod_dbd.html
[`mod_disk_cache`]: https://httpd.apache.org/docs/2.2/mod/mod_disk_cache.html
[`mod_dumpio`]: https://httpd.apache.org/docs/2.4/mod/mod_dumpio.html
[`mod_env`]: http://httpd.apache.org/docs/current/mod/mod_env.html
[`mod_expires`]: https://httpd.apache.org/docs/current/mod/mod_expires.html
[`mod_ext_filter`]: https://httpd.apache.org/docs/current/mod/mod_ext_filter.html
[`mod_fcgid`]: https://httpd.apache.org/mod_fcgid/mod/mod_fcgid.html
[`mod_geoip`]: http://dev.maxmind.com/geoip/legacy/mod_geoip2/
[`mod_info`]: https://httpd.apache.org/docs/current/mod/mod_info.html
[`mod_ldap`]: https://httpd.apache.org/docs/2.2/mod/mod_ldap.html
[`mod_mpm_event`]: https://httpd.apache.org/docs/current/mod/event.html
[`mod_negotiation`]: https://httpd.apache.org/docs/current/mod/mod_negotiation.html
[`mod_pagespeed`]: https://developers.google.com/speed/pagespeed/module/?hl=en
[`mod_passenger`]: https://www.phusionpassenger.com/library/config/apache/reference/
[`mod_php`]: http://php.net/manual/en/book.apache.php
[`mod_proxy`]: https://httpd.apache.org/docs/current/mod/mod_proxy.html
[`mod_proxy_balancer`]: https://httpd.apache.org/docs/current/mod/mod_proxy_balancer.html
[`mod_reqtimeout`]: https://httpd.apache.org/docs/current/mod/mod_reqtimeout.html
[`mod_rewrite`]: https://httpd.apache.org/docs/current/mod/mod_rewrite.html
[`mod_security`]: https://www.modsecurity.org/
[`mod_ssl`]: https://httpd.apache.org/docs/current/mod/mod_ssl.html
[`mod_status`]: https://httpd.apache.org/docs/current/mod/mod_status.html
[`mod_version`]: https://httpd.apache.org/docs/current/mod/mod_version.html
[`mod_wsgi`]: https://modwsgi.readthedocs.org/en/latest/
[module contribution guide]: https://docs.puppet.com/forge/contributing.html
[`mpm_module`]: #mpm_module
[multi-processing module]: https://httpd.apache.org/docs/current/mpm.html

[name-based virtual hosts]: https://httpd.apache.org/docs/current/vhosts/name-based.html
[`no_proxy_uris`]: #no_proxy_uris

[open source Puppet]: https://docs.puppet.com/puppet/
[`Options`]: https://httpd.apache.org/docs/current/mod/core.html#options

[`path`]: #path
[`Peruser`]: https://www.freebsd.org/cgi/url.cgi?ports/www/apache22-peruser-mpm/pkg-descr
[`port`]: #port
[`priority`]: #defined-types-apachevhost
[`proxy_dest`]: #proxy_dest
[`proxy_dest_match`]: #proxy_dest_match
[`proxy_pass`]: #proxy_pass
[`ProxyPass`]: https://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypass
[`ProxySet`]: https://httpd.apache.org/docs/current/mod/mod_proxy.html#proxyset
[Puppet Enterprise]: https://docs.puppet.com/pe/
[Puppet Forge]: https://forge.puppet.com
[Puppet]: https://puppet.com
[Puppet module]: https://docs.puppet.com/puppet/latest/reference/modules_fundamentals.html
[Puppet module's code]: https://github.com/puppetlabs/puppetlabs-apache/blob/master/manifests/default_mods.pp
[`purge_configs`]: #purge_configs
[`purge_vhost_dir`]: #purge_vhost_dir
[Python]: https://www.python.org/

[Rack]: http://rack.github.io/
[`rack_base_uris`]: #rack_base_uris
[RFC 2616]: https://www.ietf.org/rfc/rfc2616.txt
[`RequestReadTimeout`]: https://httpd.apache.org/docs/current/mod/mod_reqtimeout.html#requestreadtimeout
[rspec-puppet]: http://rspec-puppet.com/

[`ScriptAlias`]: https://httpd.apache.org/docs/current/mod/mod_alias.html#scriptalias
[`ScriptAliasMatch`]: https://httpd.apache.org/docs/current/mod/mod_alias.html#scriptaliasmatch
[`scriptalias`]: #scriptalias
[SELinux]: http://selinuxproject.org/
[`ServerAdmin`]: https://httpd.apache.org/docs/current/mod/core.html#serveradmin
[`serveraliases`]: #serveraliases
[`ServerLimit`]: https://httpd.apache.org/docs/current/mod/mpm_common.html#serverlimit
[`ServerName`]: https://httpd.apache.org/docs/current/mod/core.html#servername
[`ServerRoot`]: https://httpd.apache.org/docs/current/mod/core.html#serverroot
[`ServerTokens`]: https://httpd.apache.org/docs/current/mod/core.html#servertokens
[`ServerSignature`]: https://httpd.apache.org/docs/current/mod/core.html#serversignature
[Service attribute restart]: http://docs.puppet.com/latest/type.html#service-attribute-restart
[`source`]: #source
[`SSLCARevocationCheck`]: https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslcarevocationcheck
[SSL certificate key file]: https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslcertificatekeyfile
[SSL chain]: https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslcertificatechainfile
[SSL encryption]: https://httpd.apache.org/docs/current/ssl/index.html
[`ssl`]: #ssl
[`ssl_cert`]: #ssl_cert
[`ssl_compression`]: #ssl_compression
[`ssl_key`]: #ssl_key
[`StartServers`]: https://httpd.apache.org/docs/current/mod/mpm_common.html#startservers
[suPHP]: http://www.suphp.org/Home.html
[`suphp_addhandler`]: #suphp_addhandler
[`suphp_configpath`]: #suphp_configpath
[`suphp_engine`]: #suphp_engine
[supported operating system]: https://forge.puppet.com/supported#puppet-supported-modules-compatibility-matrix

[`ThreadLimit`]: https://httpd.apache.org/docs/current/mod/mpm_common.html#threadlimit
[`ThreadsPerChild`]: https://httpd.apache.org/docs/current/mod/mpm_common.html#threadsperchild
[`TimeOut`]: https://httpd.apache.org/docs/current/mod/core.html#timeout
[template]: http://docs.puppet.com/puppet/latest/reference/lang_template.html
[`TraceEnable`]: https://httpd.apache.org/docs/current/mod/core.html#traceenable

[`verify_config`]: #verify_config
[`vhost`]: #defined-type-apachevhost
[`vhost_dir`]: #vhost_dir
[`virtual_docroot`]: #virtual_docroot

[Web Server Gateway Interface]: https://www.python.org/dev/peps/pep-3333/#abstract
[`WSGIRestrictEmbedded`]: http://modwsgi.readthedocs.io/en/develop/configuration-directives/WSGIRestrictEmbedded.html
[`WSGIPythonPath`]: http://modwsgi.readthedocs.org/en/develop/configuration-directives/WSGIPythonPath.html
[`WSGIPythonHome`]: http://modwsgi.readthedocs.org/en/develop/configuration-directives/WSGIPythonHome.html

#### Table of Contents

1. [Module description - What is the apache module, and what does it do?][Module description]
2. [Setup - The basics of getting started with apache][Setup]
    - [What the apache module affects][apache affects]
    - [Beginning with Apache - Installation][Beginning with Apache]
3. [Usage - The classes and defined types available for configuration][Usage]
    - [Configuring virtual hosts - Examples to help get started][Configuring virtual hosts]
    - [Configuring FastCGI servers to handle PHP files][Configuring FastCGI servers]
    - [Load balancing with exported and non-exported resources][Load balancing examples]
4. [Reference - An under-the-hood peek at what the module is doing and how][Reference]
    - [Public classes][]
    - [Private classes][]
    - [Public defined types][]
    - [Private defined types][]
    - [Templates][]
5. [Limitations - OS compatibility, etc.][Limitations]
6. [Development - Guide for contributing to the module][Development]
    - [Contributing to the apache module][Contributing]
    - [Running tests - A quick guide][Running tests]

## Module description

[Apache HTTP Server][] (also called Apache HTTPD, or simply Apache) is a widely used web server. This [Puppet module][] simplifies the task of creating configurations to manage Apache servers in your infrastructure. It can configure and manage a range of virtual host setups and provides a streamlined way to install and configure [Apache modules][].

## Setup

### What the apache module affects:

- Configuration files and directories (created and written to)
  - **WARNING**: Configurations *not* managed by Puppet will be purged.
- Package/service/configuration files for Apache
- Apache modules
- Virtual hosts
- Listened-to ports
- `/etc/make.conf` on FreeBSD and Gentoo

On Gentoo, this module depends on the [`gentoo/puppet-portage`][] Puppet module. Note that while several options apply or enable certain features and settings for Gentoo, it is not a [supported operating system][] for this module.

> **Warning**: This module modifies Apache configuration files and directories and purges any configuration not managed by Puppet. Apache configuration should be managed by Puppet, as unmanaged configuration files can cause unexpected failures.
>
>To temporarily disable full Puppet management, set the [`purge_configs`][] parameter in the [`apache`][] class declaration to false. We recommend this only as a temporary means of saving and relocating customized configurations.

### Beginning with Apache

To have Puppet install Apache with the default parameters, declare the [`apache`][] class:

``` puppet
class { 'apache': }
```

When you declare this class with the default options, the module:

- Installs the appropriate Apache software package and [required Apache modules](#default_mods) for your operating system.
- Places the required configuration files in a directory, with the [default location](#conf_dir) Depends on operating system.
- Configures the server with a default virtual host and standard port ('80') and address ('\*') bindings.
- Creates a document root directory Depends on operating system, typically `/var/www`.
- Starts the Apache service.

Apache defaults depend on your operating system. These defaults work in testing environments but are not suggested for production. We recommend customizing the class's parameters to suit your site.

For instance, this declaration installs Apache without the apache module's [default virtual host configuration][Configuring virtual hosts], allowing you to customize all Apache virtual hosts:

``` puppet
class { 'apache':
  default_vhost => false,
}
```

> **Note**: When `default_vhost` is set to `false`, you have to add at least one `apache::vhost` resource or Apache will not start. To establish a default virtual host, either set the `default_vhost` in the `apache` class or use the [`apache::vhost`][] defined type. You can also configure additional specific virtual hosts with the [`apache::vhost`][] defined type.

## Usage

### Configuring virtual hosts

The default [`apache`][] class sets up a virtual host on port 80, listening on all interfaces and serving the [`docroot`][] parameter's default directory of `/var/www`.


To configure basic [name-based virtual hosts][], specify the [`port`][] and [`docroot`][] parameters in the [`apache::vhost`][] defined type:

``` puppet
apache::vhost { 'vhost.example.com':
  port    => '80',
  docroot => '/var/www/vhost',
}
```

See the [`apache::vhost`][] defined type's reference for a list of all virtual host parameters.

> **Note**: Apache processes virtual hosts in alphabetical order, and server administrators can prioritize Apache's virtual host processing by prefixing a virtual host's configuration file name with a number. The [`apache::vhost`][] defined type applies a default [`priority`][] of 15, which Puppet interprets by prefixing the virtual host's file name with `15-`. This all means that if multiple sites have the same priority, or if you disable priority numbers by setting the `priority` parameter's value to false, Apache still processes virtual hosts in alphabetical order.

To configure user and group ownership for `docroot`, use the [`docroot_owner`][] and [`docroot_group`][] parameters:

``` puppet
apache::vhost { 'user.example.com':
  port          => '80',
  docroot       => '/var/www/user',
  docroot_owner => 'www-data',
  docroot_group => 'www-data',
}
```

#### Configuring virtual hosts with SSL

To configure a virtual host to use [SSL encryption][] and default SSL certificates, set the [`ssl`][] parameter. You must also specify the [`port`][] parameter, typically with a value of '443', to accommodate HTTPS requests:

``` puppet
apache::vhost { 'ssl.example.com':
  port    => '443',
  docroot => '/var/www/ssl',
  ssl     => true,
}
```

To configure a virtual host to use SSL and specific SSL certificates, use the paths to the certificate and key in the [`ssl_cert`][] and [`ssl_key`][] parameters, respectively:

``` puppet
apache::vhost { 'cert.example.com':
  port     => '443',
  docroot  => '/var/www/cert',
  ssl      => true,
  ssl_cert => '/etc/ssl/fourth.example.com.cert',
  ssl_key  => '/etc/ssl/fourth.example.com.key',
}
```

To configure a mix of SSL and unencrypted virtual hosts at the same domain, declare them with separate [`apache::vhost`][] defined types:

``` puppet
# The non-ssl virtual host
apache::vhost { 'mix.example.com non-ssl':
  servername => 'mix.example.com',
  port       => '80',
  docroot    => '/var/www/mix',
}

# The SSL virtual host at the same domain
apache::vhost { 'mix.example.com ssl':
  servername => 'mix.example.com',
  port       => '443',
  docroot    => '/var/www/mix',
  ssl        => true,
}
```

To configure a virtual host to redirect unencrypted connections to SSL, declare them with separate [`apache::vhost`][] defined types and redirect unencrypted requests to the virtual host with SSL enabled:

``` puppet
apache::vhost { 'redirect.example.com non-ssl':
  servername      => 'redirect.example.com',
  port            => '80',
  docroot         => '/var/www/redirect',
  redirect_status => 'permanent',
  redirect_dest   => 'https://redirect.example.com/'
}

apache::vhost { 'redirect.example.com ssl':
  servername => 'redirect.example.com',
  port       => '443',
  docroot    => '/var/www/redirect',
  ssl        => true,
}
```

#### Configuring virtual host port and address bindings

Virtual hosts listen on all IP addresses ('\*') by default. To configure the virtual host to listen on a specific IP address, use the [`ip`][] parameter:

``` puppet
apache::vhost { 'ip.example.com':
  ip      => '127.0.0.1',
  port    => '80',
  docroot => '/var/www/ip',
}
```

You can also configure more than one IP address per virtual host by using an array of IP addresses for the [`ip`][] parameter:

``` puppet
apache::vhost { 'ip.example.com':
  ip      => ['127.0.0.1','169.254.1.1'],
  port    => '80',
  docroot => '/var/www/ip',
}
```

You can configure multiple ports per virtual host by using an array of ports for the [`port`][] parameter:

``` puppet
apache::vhost { 'ip.example.com':
  ip      => ['127.0.0.1'],
  port    => ['80','8080']
  docroot => '/var/www/ip',
}
```

To configure a virtual host with [aliased servers][], refer to the aliases using the [`serveraliases`][] parameter:

``` puppet
apache::vhost { 'aliases.example.com':
  serveraliases => [
    'aliases.example.org',
    'aliases.example.net',
  ],
  port          => '80',
  docroot       => '/var/www/aliases',
}
```

To set up a virtual host with a wildcard alias for the subdomain mapped to a directory of the same name, such as 'http://example.com.loc' mapped to `/var/www/example.com`, define the wildcard alias using the [`serveraliases`][] parameter and the document root with the [`virtual_docroot`][] parameter:

``` puppet
apache::vhost { 'subdomain.loc':
  vhost_name      => '*',
  port            => '80',
  virtual_docroot => '/var/www/%-2+',
  docroot         => '/var/www',
  serveraliases   => ['*.loc',],
}
```

To configure a virtual host with [filter rules][], pass the filter directives as an [array][] using the [`filters`][] parameter:

``` puppet
apache::vhost { 'subdomain.loc':
  port    => '80',
  filters => [
    'FilterDeclare  COMPRESS',
    'FilterProvider COMPRESS DEFLATE resp=Content-Type $text/html',
    'FilterChain    COMPRESS',
    'FilterProtocol COMPRESS DEFLATE change=yes;byteranges=no',
  ],
  docroot => '/var/www/html',
}
```

#### Configuring virtual hosts for apps and processors

To set up a virtual host with [suPHP][], use the following parameters:

* [`suphp_engine`][], to enable the suPHP engine.
* [`suphp_addhandler`][], to define a MIME type.
* [`suphp_configpath`][], to set which path suPHP passes to the PHP interpreter.
* [`directory`][], to configure Directory, File, and Location directive blocks.

For example:

``` puppet
apache::vhost { 'suphp.example.com':
  port             => '80',
  docroot          => '/home/appuser/myphpapp',
  suphp_addhandler => 'x-httpd-php',
  suphp_engine     => 'on',
  suphp_configpath => '/etc/php5/apache2',
  directories      => [
    { 'path'  => '/home/appuser/myphpapp',
      'suphp' => {
        user  => 'myappuser',
        group => 'myappgroup',
      },
    },
  ],
}
```

To configure a virtual host to use the [Web Server Gateway Interface][] (WSGI) for [Python][] applications, use the `wsgi` set of parameters:

``` puppet
apache::vhost { 'wsgi.example.com':
  port                        => '80',
  docroot                     => '/var/www/pythonapp',
  wsgi_application_group      => '%{GLOBAL}',
  wsgi_daemon_process         => 'wsgi',
  wsgi_daemon_process_options => {
    processes    => '2',
    threads      => '15',
    display-name => '%{GROUP}',
  },
  wsgi_import_script          => '/var/www/demo.wsgi',
  wsgi_import_script_options  => {
    process-group     => 'wsgi',
    application-group => '%{GLOBAL}',
  },
  wsgi_process_group          => 'wsgi',
  wsgi_script_aliases         => { '/' => '/var/www/demo.wsgi' },
}
```

As of Apache 2.2.16, Apache supports [FallbackResource][], a simple replacement for common RewriteRules. You can set a FallbackResource using the [`fallbackresource`][] parameter:

``` puppet
apache::vhost { 'wordpress.example.com':
  port             => '80',
  docroot          => '/var/www/wordpress',
  fallbackresource => '/index.php',
}
```

> **Note**: The `fallbackresource` parameter only supports the 'disabled' value since Apache 2.2.24.

To configure a virtual host with a designated directory for [Common Gateway Interface][] (CGI) files, use the [`scriptalias`][] parameter to define the `cgi-bin` path:

``` puppet
apache::vhost { 'cgi.example.com':
  port        => '80',
  docroot     => '/var/www/cgi',
  scriptalias => '/usr/lib/cgi-bin',
}
```

To configure a virtual host for [Rack][], use the [`rack_base_uris`][] parameter:

``` puppet
apache::vhost { 'rack.example.com':
  port           => '80',
  docroot        => '/var/www/rack',
  rack_base_uris => ['/rackapp1', '/rackapp2'],
}
```

#### Configuring IP-based virtual hosts

You can configure [IP-based virtual hosts][] to listen on any port and have them respond to requests on specific IP addresses. In this example, the server listens on ports 80 and 81, because the example virtual hosts are _not_ declared with a [`port`][] parameter:

``` puppet
apache::listen { '80': }

apache::listen { '81': }
```

Configure the IP-based virtual hosts with the [`ip_based`][] parameter:

``` puppet
apache::vhost { 'first.example.com':
  ip       => '10.0.0.10',
  docroot  => '/var/www/first',
  ip_based => true,
}

apache::vhost { 'second.example.com':
  ip       => '10.0.0.11',
  docroot  => '/var/www/second',
  ip_based => true,
}
```

You can also configure a mix of IP- and [name-based virtual hosts][] in any combination of [SSL][SSL encryption] and unencrypted configurations. 

In this example, we add two IP-based virtual hosts on an IP address (in this example, 10.0.0.10). One uses SSL and the other is unencrypted:

``` puppet
apache::vhost { 'The first IP-based virtual host, non-ssl':
  servername => 'first.example.com',
  ip         => '10.0.0.10',
  port       => '80',
  ip_based   => true,
  docroot    => '/var/www/first',
}

apache::vhost { 'The first IP-based vhost, ssl':
  servername => 'first.example.com',
  ip         => '10.0.0.10',
  port       => '443',
  ip_based   => true,
  docroot    => '/var/www/first-ssl',
  ssl        => true,
}
```

Next, we add two name-based virtual hosts listening on a second IP address (10.0.0.20):

``` puppet
apache::vhost { 'second.example.com':
  ip      => '10.0.0.20',
  port    => '80',
  docroot => '/var/www/second',
}

apache::vhost { 'third.example.com':
  ip      => '10.0.0.20',
  port    => '80',
  docroot => '/var/www/third',
}
```

To add name-based virtual hosts that answer on either 10.0.0.10 or 10.0.0.20, you **must** disable the Apache default `Listen 80`, as it conflicts with the preceding IP-based virtual hosts. To do this, set the [`add_listen`][] parameter to `false`:

``` puppet
apache::vhost { 'fourth.example.com':
  port       => '80',
  docroot    => '/var/www/fourth',
  add_listen => false,
}

apache::vhost { 'fifth.example.com':
  port       => '80',
  docroot    => '/var/www/fifth',
  add_listen => false,
}
```

### Installing Apache modules

There are two ways to install [Apache modules][] using the Puppet apache module:

- Use the [`apache::mod::<MODULE NAME>`][] classes to [install specific Apache modules with parameters][Installing specific modules].
- Use the [`apache::mod`][] defined type to [install arbitrary Apache modules][Installing arbitrary modules].

#### Installing specific modules

The Puppet apache module supports installing many common [Apache modules][], often with parameterized configuration options. For a list of supported Apache modules, see the [`apache::mod::<MODULE NAME>`][] class references.

For example, you can install the `mod_ssl` Apache module with default settings by declaring the [`apache::mod::ssl`][] class:

``` puppet
class { 'apache::mod::ssl': }
```

[`apache::mod::ssl`][] has several parameterized options that you can set when declaring it. For instance, to enable `mod_ssl` with compression enabled, set the [`ssl_compression`][] parameter to true:

``` puppet
class { 'apache::mod::ssl':
  ssl_compression => true,
}
```

Note that some modules have prerequisites, which are documented in their references under [`apache::mod::<MODULE NAME>`][].

#### Installing arbitrary modules

You can pass the name of any module that your operating system's package manager can install to the [`apache::mod`][] defined type to install it. Unlike the specific-module classes, the [`apache::mod`][] defined type doesn't tailor the installation based on other installed modules or with specific parameters---Puppet only grabs and installs the module's package, leaving detailed configuration up to you.

For example, to install the [`mod_authnz_external`][] Apache module, declare the defined type with the 'mod_authnz_external' name:

``` puppet
apache::mod { 'mod_authnz_external': }
```

There are several optional parameters you can specify when defining Apache modules this way. See the [defined type's reference][`apache::mod`] for details.

### Configuring FastCGI servers to handle PHP files

Add the [`apache::fastcgi::server`][] defined type to allow [FastCGI][] servers to handle requests for specific files. For example, the following defines a FastCGI server at 127.0.0.1 (localhost) on port 9000 to handle PHP requests:

``` puppet
apache::fastcgi::server { 'php':
  host       => '127.0.0.1:9000',
  timeout    => 15,
  flush      => false,
  faux_path  => '/var/www/php.fcgi',
  fcgi_alias => '/php.fcgi',
  file_type  => 'application/x-httpd-php'
}
```

You can then use the [`custom_fragment`][] parameter to configure the virtual host to have the FastCGI server handle the specified file type:

``` puppet
apache::vhost { 'www':
  ...
  custom_fragment => 'AddType application/x-httpd-php .php'
  ...
}
```

### Load balancing examples

Apache supports load balancing across groups of servers through the [`mod_proxy`][] Apache module. Puppet supports configuring Apache load balancing groups (also known as balancer clusters) through the [`apache::balancer`][] and [`apache::balancermember`][] defined types.

To enable load balancing with [exported resources][], export the [`apache::balancermember`][] defined type from the load balancer member server:

``` puppet
@@apache::balancermember { "${::fqdn}-puppet00":
  balancer_cluster => 'puppet00',
  url              => "ajp://${::fqdn}:8009",
  options          => ['ping=5', 'disablereuse=on', 'retry=5', 'ttl=120'],
}
```

Then, on the proxy server, create the load balancing group:

``` puppet
apache::balancer { 'puppet00': }
```

To enable load balancing without exporting resources, declare the following on the proxy server:

``` puppet
apache::balancer { 'puppet00': }

apache::balancermember { "${::fqdn}-puppet00":
  balancer_cluster => 'puppet00',
  url              => "ajp://${::fqdn}:8009",
  options          => ['ping=5', 'disablereuse=on', 'retry=5', 'ttl=120'],
}
```

Then declare the `apache::balancer` and `apache::balancermember` defined types on the proxy server.

To use the [ProxySet](https://httpd.apache.org/docs/current/mod/mod_proxy.html#proxyset) directive on the balancer, use the [`proxy_set`](#proxy_set) parameter of `apache::balancer`:

``` puppet
apache::balancer { 'puppet01':
  proxy_set => {
    'stickysession' => 'JSESSIONID',
    'lbmethod'      => 'bytraffic',
  },
}
```

Load balancing scheduler algorithms (`lbmethod`) are listed [in mod_proxy_balancer documentation](https://httpd.apache.org/docs/current/mod/mod_proxy_balancer.html).

## Reference

- [**Public classes**](#public-classes)
    - [Class: apache](#class-apache)
    - [Class: apache::dev](#class-apachedev)
    - [Class: apache::vhosts](#class-apachevhosts)
    - [Classes: apache::mod::\*](#classes-apachemodname)
- [**Private classes**](#private-classes)
    - [Class: apache::confd::no_accf](#class-apacheconfdno_accf)
    - [Class: apache::default_confd_files](#class-apachedefault_confd_files)
    - [Class: apache::default_mods](#class-apachedefault_mods)
    - [Class: apache::package](#class-apachepackage)
    - [Class: apache::params](#class-apacheparams)
    - [Class: apache::service](#class-apacheservice)
    - [Class: apache::version](#class-apacheversion)
- [**Public defined types**](#public-defined-types)
    - [Defined type: apache::balancer](#defined-type-apachebalancer)
    - [Defined type: apache::balancermember](#defined-type-apachebalancermember)
    - [Defined type: apache::custom_config](#defined-type-apachecustom_config)
    - [Defined type: apache::fastcgi::server](#defined-type-fastcgi-server)
    - [Defined type: apache::listen](#defined-type-apachelisten)
    - [Defined type: apache::mod](#defined-type-apachemod)
    - [Defined type: apache::namevirtualhost](#defined-type-apachenamevirtualhost)
    - [Defined type: apache::vhost](#defined-type-apachevhost)
    - [Defined type: apache::vhost::custom](#defined-type-apachevhostcustom)
- [**Private defined types**](#private-defined-types)
    - [Defined type: apache::default_mods::load](#defined-type-default_mods-load)
    - [Defined type: apache::peruser::multiplexer](#defined-type-apacheperusermultiplexer)
    - [Defined type: apache::peruser::processor](#defined-type-apacheperuserprocessor)
    - [Defined type: apache::security::file_link](#defined-type-apachesecurityfile_link)
- [**Templates**](#templates)

### Public Classes

#### Class: `apache`

Guides the basic setup and installation of Apache on your system.

When this class is declared with the default options, Puppet:

- Installs the appropriate Apache software package and [required Apache modules](#default_mods) for your operating system.
- Places the required configuration files in a directory, with the [default location](#conf_dir) determined by your operating system.
- Configures the server with a default virtual host and standard port ('80') and address ('\*') bindings.
- Creates a document root directory determined by your operating system, typically `/var/www`.
- Starts the Apache service.

You can simply declare the default `apache` class:

``` puppet
class { 'apache': }
```

##### `allow_encoded_slashes`

Sets the server default for the [`AllowEncodedSlashes`][] declaration, which modifies the responses to URLs containing '\' and '/' characters. If not specified, this parameter omits the declaration from the server's configuration and uses Apache's default setting of 'off'.

Values: 'on', 'off', 'nodecode'. 

Default: `undef`.

##### `apache_version`

Configures module template behavior, package names, and default Apache modules by defining the version of Apache to use. We do not recommend manually configuring this parameter without reason.

Default: Depends on operating system and release version detected by the [`apache::version`][] class. 

##### `conf_dir`

Sets the directory where the Apache server's main configuration file is located.

Default: Depends on operating system.

- **Debian**: `/etc/apache2`
- **FreeBSD**: `/usr/local/etc/apache22`
- **Gentoo**: `/etc/apache2`
- **Red Hat**: `/etc/httpd/conf`

##### `conf_template`

Defines the [template][] used for the main Apache configuration file. Modifying this parameter is potentially risky, as the apache module is designed to use a minimal configuration file customized by `conf.d` entries.

Default: `apache/httpd.conf.erb`.

##### `confd_dir`

Sets the location of the Apache server's custom configuration directory. 

Default: Depends on operating system.

- **Debian**: `/etc/apache2/conf.d`
- **FreeBSD**: `/usr/local/etc/apache22`
- **Gentoo**: `/etc/apache2/conf.d`
- **Red Hat**: `/etc/httpd/conf.d`

##### `default_charset`

Used as the [`AddDefaultCharset`][] directive in the main configuration file.

Default: `undef`.

##### `default_confd_files`

Determines whether Puppet generates a default set of includable Apache configuration files in the directory defined by the [`confd_dir`][] parameter. These configuration files correspond to what is typically installed with the Apache package on the server's operating system.

Boolean. Default: `true`.

##### `default_mods`

Determines whether to configure and enable a set of default [Apache modules][] depending on your operating system.

If `false`, Puppet includes only the Apache modules required to make the HTTP daemon work on your operating system, and you can declare any other modules separately using the [`apache::mod::<MODULE NAME>`][] class or [`apache::mod`][] defined type.

If `true`, Puppet installs additional modules, depending on the operating system and the values of [`apache_version`][] and [`mpm_module`][] parameters. Because these lists of modules can change frequently, consult the [Puppet module's code][] for up-to-date lists.

If this parameter contains an array, Puppet instead enables all passed Apache modules.

Values: Boolean or an array of Apache module names.

Default: `true`.

##### `default_ssl_ca`

Sets the default certificate authority for the Apache server.

Although the default value results in a functioning Apache server, you **must** update this parameter with your certificate authority information before deploying this server in a production environment.

Boolean. Default: `undef`.

##### `default_ssl_cert`

Sets the [SSL encryption][] certificate location.

Although the default value results in a functioning Apache server, you **must** update this parameter with your certificate location before deploying this server in a production environment.

Default: Depends on operating system.

- **Debian**: `/etc/ssl/certs/ssl-cert-snakeoil.pem`
- **FreeBSD**: `/usr/local/etc/apache22/server.crt`
- **Gentoo**: `/etc/ssl/apache2/server.crt`
- **Red Hat**: `/etc/pki/tls/certs/localhost.crt`

##### `default_ssl_chain`

Sets the default [SSL chain][] location.

Although this default value results in a functioning Apache server, you **must** update this parameter with your SSL chain before deploying this server in a production environment.

Default: `undef`.

##### `default_ssl_crl`

Sets the path of the default [certificate revocation list][] (CRL) file to use.

Although this default value results in a functioning Apache server, you **must** update this parameter with the CRL file path before deploying this server in a production environment. You can use this parameter with or in place of the [`default_ssl_crl_path`][].

Default: `undef`.

##### `default_ssl_crl_path`

Sets the server's [certificate revocation list path][], which contains your CRLs.

Although this default value results in a functioning Apache server, you **must** update this parameter with the CRL file path before deploying this server in a production environment.

Default: `undef`.

##### `default_ssl_crl_check`

Sets the default certificate revocation check level via the [`SSLCARevocationCheck`][] directive. This parameter applies only to Apache 2.4 or higher and is ignored on older versions.

Although this default value results in a functioning Apache server, you **must** specify this parameter when using certificate revocation lists in a production environment.

Default: `undef`.

##### `default_ssl_key`

Sets the [SSL certificate key file][] location.

Although the default values result in a functioning Apache server, you **must** update this parameter with your SSL key's location before deploying this server in a production environment.

Default: Depends on operating system.

- **Debian**: `/etc/ssl/private/ssl-cert-snakeoil.key`
- **FreeBSD**: `/usr/local/etc/apache22/server.key`
- **Gentoo**: `/etc/ssl/apache2/server.key`
- **Red Hat**: `/etc/pki/tls/private/localhost.key`


##### `default_ssl_vhost`

Configures a default [SSL][SSL encryption] virtual host. 

If `true`, Puppet automatically configures the following virtual host using the [`apache::vhost`][] defined type:

```puppet
apache::vhost { 'default-ssl':
  port            => 443,
  ssl             => true,
  docroot         => $docroot,
  scriptalias     => $scriptalias,
  serveradmin     => $serveradmin,
  access_log_file => "ssl_${access_log_file}",
  }
```

> **Note**: SSL virtual hosts only respond to HTTPS queries.


Boolean. Default: `false`.

##### `default_type`

_Apache 2.2 only_. Sets the [MIME `content-type`][] sent if the server cannot otherwise determine an appropriate `content-type`. This directive is deprecated in Apache 2.4 and newer, and is only for backwards compatibility in configuration files.

Default: `undef`.

##### `default_vhost`

Configures a default virtual host when the class is declared. 

To configure [customized virtual hosts][Configuring virtual hosts], set this parameter's value to `false`.

> **Note**: Apache will not start without at least one virtual host. If you set this to `false` you must configure a virtual host elsewhere.

Boolean. Default: `true`.

##### `dev_packages`

Configures a specific dev package to use. 

Values: A string or array of strings.

Example for using httpd 2.4 from the IUS yum repo:

``` puppet
include ::apache::dev
class { 'apache':
  apache_name  => 'httpd24u',
  dev_packages => 'httpd24u-devel',
}
```

Default: Depends on operating system.

- **Red Hat:** 'httpd-devel'
- **Debian 8/Ubuntu 13.10 or newer:** ['libaprutil1-dev', 'libapr1-dev', 'apache2-dev']
- **Older Debian/Ubuntu versions:** ['libaprutil1-dev', 'libapr1-dev', 'apache2-prefork-dev']
- **FreeBSD, Gentoo:** `undef`
- **Suse:** ['libapr-util1-devel', 'libapr1-devel']

##### `docroot`

Sets the default [`DocumentRoot`][] location.

Default: Depends on operating system.

- **Debian**: `/var/www/html`
- **FreeBSD**: `/usr/local/www/apache22/data`
- **Gentoo**: `/var/www/localhost/htdocs`
- **Red Hat**: `/var/www/html`

##### `error_documents`

Determines whether to enable [custom error documents][] on the Apache server.

Boolean. Default: `false`.

##### `group`

Sets the group ID that owns any Apache processes spawned to answer requests.

By default, Puppet attempts to manage this group as a resource under the `apache` class, determining the group based on the operating system as detected by the [`apache::params`][] class. To to prevent the group resource from being created and use a group created by another Puppet module, set the [`manage_group`][] parameter's value to `false`.

> **Note**: Modifying this parameter only changes the group ID that Apache uses to spawn child processes to access resources. It does not change the user that owns the parent server process.

##### `httpd_dir`

Sets the Apache server's base configuration directory. This is useful for specially repackaged Apache server builds but might have unintended consequences when combined with the default distribution packages.

Default: Depends on operating system.

- **Debian**: `/etc/apache2`
- **FreeBSD**: `/usr/local/etc/apache22`
- **Gentoo**: `/etc/apache2`
- **Red Hat**: `/etc/httpd`

##### http_protocol_options`

Specifies the strictness of HTTP protocol checks. Valid options: any sequence of the following alternative values: `Strict` or `Unsafe`, `RegisteredMethods` or `LenientMethods`, and `Allow0.9` or `Require1.0`. Default '`Strict LenientMethods Allow0.9`'.

##### `keepalive`

Determines whether to enable persistent HTTP connections with the [`KeepAlive`][] directive. If you set this to 'On', use the [`keepalive_timeout`][] and [`max_keepalive_requests`][] parameters to set relevant options.

Values: 'Off', 'On'.

Default: 'Off'.

##### `keepalive_timeout`

Sets the [`KeepAliveTimeout`] directive, which determines the amount of time the Apache server waits for subsequent requests on a persistent HTTP connection. This parameter is only relevant if the [`keepalive` parameter][] is enabled.

Default: '15'.

##### `max_keepalive_requests`

Limits the number of requests allowed per connection when the [`keepalive` parameter][] is enabled.

Default: '100'.

##### `lib_path`

Specifies the location where [Apache module][Apache modules] files are stored. Default: Depends on operating system.

- **Debian** and **Gentoo**: `/usr/lib/apache2/modules`
- **FreeBSD**: `/usr/local/libexec/apache24`
- **Red Hat**: `modules`

> **Note**: Do not configure this parameter manually without special reason.

##### `log_level`

Changes the error log's verbosity. Values: 'alert', 'crit', 'debug', 'emerg', 'error', 'info', 'notice', 'warn'.

Default: 'warn'.

##### `log_formats`

Define additional [`LogFormat`][] directives. Values: A [hash][], such as:

``` puppet
$log_formats = { vhost_common => '%v %h %l %u %t \"%r\" %>s %b' }
```

There are a number of predefined `LogFormats` in the `httpd.conf` that Puppet creates:

``` httpd
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %b" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent
LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %s %b \"%{Referer}i\" \"%{User-agent}i\"" forwarded
```

If your `log_formats` parameter contains one of those, it will be overwritten with **your** definition.

##### `logroot`

Changes the directory of Apache log files for the virtual host.

Default: Depends on operating system.

- **Debian**: `/var/log/apache2`
- **FreeBSD**: `/var/log/apache22`
- **Gentoo**: `/var/log/apache2`
- **Red Hat**: `/var/log/httpd`

##### `logroot_mode`

Overrides the default [`logroot`][] directory's mode.

> **Note**: Do _not_ grant write access to the directory where the logs are stored without being aware of the consequences. See the [Apache documentation][Log security] for details.

Default: `undef`.

##### `manage_group`

When `false`, stops Puppet from creating the group resource.

If you have a group created from another Puppet module that you want to use to run Apache, set this to `false`. Without this parameter, attempting to use a previously established group results in a duplicate resource error.

Boolean. Default: `true`.

##### `supplementary_groups`

A list of groups to which the user belongs. These groups are in addition to the primary group. Default: No additional groups.

Notice: This option only has an effect when `manage_user` is set to true.

##### `manage_user`

When `false`, stops Puppet from creating the user resource.

This is for instances when you have a user, created from another Puppet module, you want to use to run Apache. Without this parameter, attempting to use a previously established user would result in a duplicate resource error.

Boolean. Default: `true`.

##### `mod_dir`

Sets where Puppet places configuration files for your [Apache modules][].

Default: Depends on operating system.

- **Debian**: `/etc/apache2/mods-available`
- **FreeBSD**: `/usr/local/etc/apache22/Modules`
- **Gentoo**: `/etc/apache2/modules.d`
- **Red Hat**: `/etc/httpd/conf.d`

##### `mod_packages`

Allows the user to override default module package names.

```puppet
include apache::params
class { 'apache':
  mod_packages => merge($::apache::params::mod_packages, {
    'auth_kerb' => 'httpd24-mod_auth_kerb',
  })
}
```

Hash. Default: `$apache::params::mod_packages`

##### `mpm_module`

Determines which [multi-processing module][] (MPM) is loaded and configured for the HTTPD process. Values: 'event', 'itk', 'peruser', 'prefork', 'worker', or `false`.

You must set this to `false` to explicitly declare the following classes with custom parameters:

- [`apache::mod::event`][]
- [`apache::mod::itk`][]
- [`apache::mod::peruser`][]
- [`apache::mod::prefork`][]
- [`apache::mod::worker`][]

Default: Depends on operating system.

- **Debian**: 'worker'
- **FreeBSD, Gentoo, and Red Hat**: 'prefork'

##### `package_ensure`

Controls the `package` resource's [`ensure`][] attribute. Values: 'absent', 'installed' (or equivalent 'present'), or a version string.

Default: 'installed'.
 
##### `pidfile`

Allows settting a custom location for the pid file. Useful if using a custom-built Apache rpm.

Default: Depends on operating system.

- **Debian:** '\${APACHE_PID_FILE}'
- **FreeBSD:** '/var/run/httpd.pid'
- **Red Hat:** 'run/httpd.pid'

##### `ports_file`

Sets the path to the file containing Apache ports configuration.

Default: '{$conf_dir}/ports.conf'.

##### `purge_configs`

Removes all other Apache configs and virtual hosts.

Setting this to `false` is a stopgap measure to allow the apache module to coexist with existing or unmanaged configurations. We recommend moving your configuration to resources within this module. For virtual host configurations, see [`purge_vhost_dir`][].

Boolean. Default: `true`.

##### `purge_vhost_dir`

If the [`vhost_dir`][] parameter's value differs from the [`confd_dir`][] parameter's, this parameter determines whether Puppet removes any configurations inside `vhost_dir` that are _not_ managed by Puppet.

Setting `purge_vhost_dir` to `false` is a stopgap measure to allow the apache module to coexist with existing or otherwise unmanaged configurations within `vhost_dir`.

Boolean. Default: same as [`purge_configs`][].

##### `rewrite_lock`

Allows setting a custom location for a rewrite lock - considered best practice if using a RewriteMap of type prg in the [`rewrites`][] parameter of your virtual host. This parameter only applies to Apache version 2.2 or lower and is ignored on newer versions.

Default: `undef`.

##### `sendfile`

Forces Apache to use the Linux kernel's `sendfile` support to serve static files, via the [`EnableSendfile`][] directive. Values: 'On', 'Off'.

Default: 'On'.

##### `serveradmin`

Sets the Apache server administrator's contact information via Apache's [`ServerAdmin`][] directive.

Default: 'root@localhost'.

##### `servername`

Sets the Apache server name via Apache's [`ServerName`][] directive. 

Setting to `false` will not set ServerName at all.

Default: the 'fqdn' fact reported by [Facter][].

##### `server_root`

Sets the Apache server's root directory via Apache's [`ServerRoot`][] directive.

Default: Depends on operating system.

- **Debian**: `/etc/apache2`
- **FreeBSD**: `/usr/local`
- **Gentoo**: `/var/www`
- **Red Hat**: `/etc/httpd`

##### `server_signature`

Configures a trailing footer line to display at the bottom of server-generated documents, such as error documents and output of certain [Apache modules][], via Apache's [`ServerSignature`][] directive. Values: 'Off', 'On'.

Default: 'On'.

##### `server_tokens`

Controls how much information Apache sends to the browser about itself and the operating system, via Apache's [`ServerTokens`][] directive.

Default: 'OS'.

##### `service_enable`

Determines whether Puppet enables the Apache HTTPD service when the system is booted.

Boolean. Default: `true`.

##### `service_ensure`

Determines whether Puppet should make sure the service is running. Values: `true` (or 'running'), `false` (or 'stopped'). 

The `false` or 'stopped' values set the 'httpd' service resource's `ensure` parameter to `false`, which is useful when you want to let the service be managed by another application, such as Pacemaker.

Default: 'running'.

##### `service_name`

Sets the name of the Apache service.

Default: Depends on operating system.

- **Debian and Gentoo**: 'apache2'
- **FreeBSD**: 'apache22'
- **Red Hat**: 'httpd'

##### `service_manage`

Determines whether Puppet manages the HTTPD service's state.

Boolean. Default: `true`.

##### `service_restart`

Determines whether Puppet should use a specific command to restart the HTTPD service.

Values: a command to restart the Apache service. The default setting uses the [default Puppet behavior][Service attribute restart].

Default: `undef`.

##### `ssl_ca`

Specifies the SSL certificate authority. [SSLCACertificateFile](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslcacertificatefile). Default: undef. It is possible to override this on a vhost level.














##### `timeout`

Sets Apache's [`TimeOut`][] directive, which defines the number of seconds Apache waits for certain events before failing a request.

Default: 120.

##### `trace_enable`

Controls how Apache handles `TRACE` requests (per [RFC 2616][]) via the [`TraceEnable`][] directive.

Values: 'Off', 'On'.

Default: 'On'.

##### `use_systemd`

Controls whether the systemd module should be installed on Centos 7 servers, this is especially useful if using custom-built RPMs.

Boolean. Default: `true`.

##### `file_mode`

Sets the desired permissions mode for config files.

Values: A string, with permissions mode in symbolic or numeric notation.

Default: '0644'.

##### `root_directory_options`

Array of the desired options for the / directory in httpd.conf. Defaults to 'FollowSymLinks'.

##### `root_directory_secured`

Sets the default access policy for the / directory in httpd.conf. A value of `false` allows access to all resources that are missing a more specific access policy. A value of `true` denies access to all resources by default. If `true`, more specific rules must be used to allow access to these resources (for example, in a directory block using the [`directories`](#parameter-directories-for-apachevhost) parameter).

Boolean. Default: `false`.

##### `vhost_dir`

Changes your virtual host configuration files' location.

Default: Depends on operating system:

- **Debian**: `/etc/apache2/sites-available`
- **FreeBSD**: `/usr/local/etc/apache22/Vhosts`
- **Gentoo**: `/etc/apache2/vhosts.d`
- **Red Hat**: `/etc/httpd/conf.d`

##### `vhost_include_pattern`

Defines the pattern for files included from the `vhost_dir`.

If set to a value like `[^.#]\*.conf[^~]` to make sure that files accidentally created in this directory (such as files created by version control systems or editor backups) are *not* included in your server configuration.

Default: '*', also for BC with previous versions of this module. TODO: what does "also for BC" mean?
 
Some operating systems use a value of `*.conf`. By default, this module creates configuration files ending in `.conf`.

##### `user`

Changes the user that Apache uses to answer requests. Apache's parent process continues to run as root, but child processes access resources as the user defined by this parameter. To prevent Puppet from managing the user, set the [`manage_user`][] parameter to `false`.

Default: Depends on the user set by [`apache::params`][] class, based on your operating system:

- **Debian**: 'www-data'
- **FreeBSD**: 'www'
- **Gentoo** and **Red Hat**: 'apache'

To prevent Puppet from managing the user, set the [`manage_user`][] parameter to false.

##### `apache_name`

The name of the Apache package to install. If you are using a non-standard Apache package, such as those from Red Hat's software collections, you might need to override the default setting.

Default: Depends on the user set by [`apache::params`][] class, based on your operating system:

- **Debian**: 'apache2'
- **FreeBSD**: 'apache24'
- **Gentoo**: 'www-servers/apache'
- **Red Hat**: 'httpd'

##### `error_log`

The name of the error log file for the main server instance. If the string starts with `/`, `|`, or `syslog`: the full path is set. Otherwise, the filename  is prefixed with `$logroot`.

Default: Depends on operating system:

- **Debian**: 'error.log'
- **FreeBSD**: 'httpd-error.log'
- **Gentoo**: 'error.log'
- **Red Hat**: 'error_log'
- **Suse**: 'error.log'

##### `scriptalias`

Directory to use for global script alias 

Default: Depends on operating system:

- **Debian**: '/usr/lib/cgi-bin'
- **FreeBSD**: '/usr/local/www/apache24/cgi-bin'
- **Gentoo**: 'var/www/localhost/cgi-bin'
- **Red Hat**: '/var/www/cgi-bin'
- **Suse**: '/usr/lib/cgi-bin'

##### `access_log_file`

The name of the access log file for the main server instance.

Default: Depends on operating system:

- **Debian**: 'error.log'
- **FreeBSD**: 'httpd-access.log'
- **Gentoo**: 'access.log'
- **Red Hat**: 'access_log'
- **Suse**: 'access.log'

#### Class: `apache::dev`

Installs Apache development libraries. Default: Depends on the operating system:[`dev_packages`][] parameter of the [`apache::params`][] class, based on your operating system:

- **Debian** : 'libaprutil1-dev', 'libapr1-dev'; 'apache2-dev' on Ubuntu 13.10 and Debian 8; 'apache2-prefork-dev' on other versions.
- **FreeBSD**: `undef`; on FreeBSD, you must declare the `apache::package` or `apache` classes before declaring `apache::dev`.
- **Gentoo**: `undef`.
- **Red Hat**: 'httpd-devel'.

#### Class: `apache::vhosts`

Creates [`apache::vhost`][] defined types.

**Parameters**:

* `vhosts`: Specifies the [`apache::vhost`][] defined type's parameters. 

  Values: A [hash][], where the key represents the name and the value represents a [hash][] of [`apache::vhost`][] defined type's parameters.

  Default: '{}'

  > **Note**: See the [`apache::vhost`][] defined type's reference for a list of all virtual host parameters or [Configuring virtual hosts].

  For example, to create a [name-based virtual host][name-based virtual hosts] 'custom_vhost_1, declare this class with the `vhosts` parameter set to '{ "custom_vhost_1" => { "docroot" => "/var/www/custom_vhost_1", "port" => "81" }':

``` puppet
class { 'apache::vhosts':
  vhosts => {
    'custom_vhost_1' => {
      'docroot' => '/var/www/custom_vhost_1',
      'port'    => '81',
    },
  },
}
```

#### Classes: `apache::mod::<MODULE NAME>`

Enables specific [Apache modules][]. Enable and configure an Apache module by declaring its class.

For example, to install and enable [`mod_alias`][] with no icons, declare the [`apache::mod::alias`][] class with the `icons_options` parameter set to 'None':

``` puppet
class { 'apache::mod::alias':
  icons_options => 'None',
}
```

The following Apache modules have supported classes, many of which allow for parameterized configuration. You can install other Apache modules with the [`apache::mod`][] defined type.

* `actions`
* `alias` (see [`apache::mod::alias`][])
* `auth_basic`
* `auth_cas`\* (see [`apache::mod::auth_cas`][])
* `auth_mellon`\* (see [`apache::mod::auth_mellon`][])
* `auth_kerb`
* `authn_core`
* `authn_dbd`\* (see [`apache::mod::authn_dbd`][])
* `authn_file`
* `authnz_ldap`\* (see [`apache::mod::authnz_ldap`][])
* `authnz_pam`
* `authz_default`
* `authz_user`
* `autoindex`
* `cache`
* `cgi`
* `cgid`
* `cluster` (see [`apache::mod::cluster`][])
* `dav`
* `dav_fs`
* `dav_svn`\*
* `dbd`
* `deflate\`
* `dev`
* `dir`\*
* `disk_cache` (see [`apache::mod::disk_cache`][])
* `dumpio` (see [`apache::mod::dumpio`][])
* `env`
* `event` (see [`apache::mod::event`][])
* `expires`
* `ext_filter` (see [`apache::mod::ext_filter`][])
* `fastcgi`
* `fcgid`
* `filter`
* `geoip` (see [`apache::mod::geoip`][])
* `headers`
* `include`
* `info`\*
* `intercept_form_submit`
* `itk`
* `ldap` (see [`apache::mod::ldap`][])
* `lookup_identity`
* `mime`
* `mime_magic`\*
* `negotiation`
* `nss`\* (see [`apache::mod::nss`][])
* `pagespeed` (see [`apache::mod::pagespeed`][])
* `passenger`\* (see [`apache::mod::passenger`][])
* `perl`
* `peruser`
* `php` (requires [`mpm_module`][] set to `prefork`)
* `prefork`\*
* `proxy`\* (see [`apache::mod::proxy`][])
* `proxy_ajp`
* `proxy_balancer`\* (see [`apache::mod::proxy_balancer`][])
* `proxy_balancer`
* `proxy_html` (see [`apache::mod::proxy_html`][])
* `proxy_http`
* `python`
* `reqtimeout`
* `remoteip`\*
* `rewrite`
* `rpaf`\*
* `setenvif`
* `security`
* `shib`\* (see [`apache::mod::shib`])
* `speling`
* `ssl`\* (see [`apache::mod::ssl`][])
* `status`\* (see [`apache::mod::status`][])
* `suphp`
* `userdir`\*
* `version`
* `vhost_alias`
* `worker`\*
* `wsgi` (see [`apache::mod::wsgi`][])
* `xsendfile`

Modules noted with a * indicate that the module has settings and a template that includes parameters to configure the module. Most Apache module class parameters have default values and don't require configuration. For modules with templates, Puppet installs template files with the module; these template files are required for the module to work.

##### Class: `apache::mod::alias`

Installs and manages [`mod_alias`][].

**Parameters**:

* `icons_options`: Disables directory listings for the icons directory, via Apache [`Options`] directive.

  Default: 'Indexes MultiViews'.

* `icons_path`: Sets the local path for an `/icons/` Alias.

  Default: Depends on operating system.

    * **Debian**: `/usr/share/apache2/icons`
    * **FreeBSD**: `/usr/local/www/apache24/icons`
    * **Gentoo**: `/var/www/icons`
    * *Red Hat**: `/var/www/icons`, except on Apache 2.4, where it's `/usr/share/httpd/icons`

#### Class: `apache::mod::disk_cache`

Installs and configures [`mod_disk_cache`][] on Apache 2.2, or [`mod_cache_disk`][] on Apache 2.4.

Default: Depends on the Apache version and operating system:

- **Debian**: `/var/cache/apache2/mod_cache_disk`
- **FreeBSD**: `/var/cache/mod_cache_disk`
- **Red Hat, Apache 2.4**: `/var/cache/httpd/proxy`
- **Red Hat, Apache 2.2**: `/var/cache/mod_proxy`

To specify the cache root, pass a path as a string to the `cache_root` parameter.

``` puppet
class {'::apache::mod::disk_cache':
  cache_root => '/path/to/cache',
}
```

##### Class: `apache::mod::diskio`

Installs and configures [`mod_diskio`][].

```puppet
class{'apache':
  default_mods => `false`,
  log_level    => 'dumpio:trace7',
}
class{'apache::mod::diskio':
  disk_io_input  => 'On',
  disk_io_output => 'Off',
}
```

**Parameters**:

* `dump_io_input`: Dump all input data to the error log.

  Values: 'On', 'Off'.
  
  Default: 'Off'.
  
* `dump_io_output`: Dump all output data to the error log.

  Values: 'On', 'Off'.

  Defaults to 'Off'.

##### Class: `apache::mod::event`

Installs and manages [`mod_mpm_event`][]. You cannot include `apache::mod::event` with [`apache::mod::itk`][], [`apache::mod::peruser`][], [`apache::mod::prefork`][], or [`apache::mod::worker`][] on the same server.

**Parameters**:

* `listenbacklog`: Sets the maximum length of the pending connections queue via the module's [`ListenBackLog`][] directive.  Setting this to `false` removes the parameter.

  Default: '511'.
  
* `maxrequestworkers` (_Apache 2.3.12 or older_: `maxclients`): Sets the maximum number of connections Apache can simultaneously process, via the module's [`MaxRequestWorkers`][] directive.  Setting these to `false` removes the parameters.

  Default: '150'.
  
* `maxconnectionsperchild` (_Apache 2.3.8 or older_: `maxrequestsperchild`): Limits the number of connections a child server handles during its life, via the module's [`MaxConnectionsPerChild`][] directive. Setting these to `false` removes the parameters.

  Default: '0'.
  
* `maxsparethreads` and `minsparethreads`: Sets the maximum and minimum number of idle threads, via the [`MaxSpareThreads`][] and [`MinSpareThreads`][] directives. Setting these to `false` removes the parameters.

  Default: '75' and '25', respectively.
  
* `serverlimit`: Limits the configurable number of processes via the [`ServerLimit`][] directive. Setting this to `false` removes the parameter.

  Default: '25'.
  
* `startservers`: Sets the number of child server processes created at startup, via the module's [`StartServers`][] directive. Setting this to `false` removes the parameter.

  Default: '2'.
  
* `threadlimit`: Limits the number of event threads via the module's [`ThreadLimit`][] directive. Setting this to `false` removes the parameter.

  Default: '64'.
  
* `threadsperchild`: Sets the number of threads created by each child process, via the [`ThreadsPerChild`][] directive. Default: '25'. Setting this to `false` removes the parameter.

##### Class: `apache::mod::auth_cas`

Installs and manages [`mod_auth_cas`][]. Parameters share names with the Apache module's directives.

The `cas_login_url` and `cas_validate_url` parameters are required; several other parameters have `undef` default values.

> **Note**: The auth_cas module isn't available on RH/CentOS without providing dependency packages provided by EPEL. See [https://github.com/Jasig/mod_auth_cas]()

**Parameters**:

- `cas_attribute_prefix`: Adds a header with the value of this header being the attribute values when SAML validation is enabled.

  Default: CAS_.
  
- `cas_attribute_delimiter`: The delimiter between attribute values in the header created by `cas_attribute_prefix`.
  
  Default: ,

- `cas_authoritative`: Determines whether an optional authorization directive is authoritative and binding.

  Default: `undef`.

- `cas_certificate_path`: Sets the path to the X509 certificate of the Certificate Authority for the server in `cas_login_url` and `cas_validate_url`.

  Default: `undef`.

- `cas_cache_clean_interval`: Sets the minimum number of seconds that must pass between cache cleanings.

  Default: `undef`.

- `cas_cookie_domain`: Sets the value of the `Domain=` parameter in the `Set-Cookie` HTTP header.

  Default: `undef`.

- `cas_cookie_entropy`: Sets the number of bytes to use when creating session identifiers. 

  Default: `undef`.

- `cas_cookie_http_only`: Sets the optional `HttpOnly` flag when `mod_auth_cas` issues cookies.

  Default: `undef`.

- `cas_cookie_path`: Where cas cookie session data is stored. Should be writable by web server user.

  Default: OS dependent.

- `cas_cookie_path_mode`: The mode of `cas_cookie_path`.

  Default: '0750'.

- `cas_debug`: Determines whether to enable the module's debugging mode.
  
  Default: 'Off'.

- `cas_idle_timeout`: Sets the idle timeout limit, in seconds.

  Default: `undef`.

- `cas_login_url`: **Required**. Sets the URL to which the module redirects users when they attempt to access a CAS-protected resource and don't have an active session.

- `cas_proxy_validate_url`: The URL to use when performing a proxy validation.

  Default: `undef`.

- `cas_root_proxied_as`: Sets the URL end users see when access to this Apache server is proxied.

  Default: `undef`.

- `cas_scrub_request_headers`: Remove inbound request headers that may have special meaning within mod_auth_cas.

- `cas_sso_enabled`: Enables experimental support for single sign out (may mangle POST data).

  Default: 'Off'.
  
- `cas_timeout`: Limits the number of seconds a `mod_auth_cas` session can remain active. 

  Default: `undef`.

- `cas_validate_depth`: Limits the depth for chained certificate validation.

  Default: `undef`.

- `cas_validate_saml`: Parse response from CAS server for SAML.

  Default: 'Off'.

- `cas_validate_server`: Whether to validate the cert of the CAS server (deprecated in 1.1 - RedHat 7).

  Default: `undef`.

- `cas_validate_url`: **Required**. Sets the URL to use when validating a client-presented ticket in an HTTP query string.

- `cas_version`: The CAS protocol version to adhere to. Values: '1', '2'.

  Default: '2'.

- `suppress_warning`: Suppress warning about being on RedHat (`mod_auth_cas` package is now available in epel-testing repo).

  Default: `false`.

##### Class: `apache::mod::auth_mellon`

Installs and manages [`mod_auth_mellon`][]. Parameters share names with the Apache module's directives.

``` puppet
class{ 'apache::mod::auth_mellon':
  mellon_cache_size => 101,
}
```

**Parameters**:

* `mellon_cache_entry_size`: Maximum size for a single session.

  Default: `undef`.

* `mellon_cache_size`: Size in megabytes of the mellon cache.

  Default: 100.

* `mellon_lock_file`: Location of lock file.

  Default: '`/run/mod_auth_mellon/lock`'.

* `mellon_post_directory`: Full path where post requests are saved.

  Default: '`/var/cache/apache2/mod_auth_mellon/`'

* `mellon_post_ttl`: Time to keep post requests.

  Default: `undef`.

* `mellon_post_size`: Maximum size of post requests.

  Default: `undef`.

* `mellon_post_count`: Maximum number of post requests.

 Default: `undef`.

##### Class: `apache::mod::authn_dbd`

Installs `mod_authn_dbd` and uses `authn_dbd.conf.erb` template to generate its configuration. Optionally, creates AuthnProviderAlias.

``` puppet
class { 'apache::mod::authn_dbd':
  $authn_dbd_params =>
    'host=db01 port=3306 user=apache password=xxxxxx dbname=apacheauth',
  $authn_dbd_query  => 'SELECT password FROM authn WHERE user = %s',
  $authn_dbd_alias  => 'db_auth',
}
```

**Parameters**:

* `authn_dbd_alias`: Name for the 'AuthnProviderAlias'.

* `authn_dbd_dbdriver`: Specifies the database driver to use.
  
  Default: 'mysql'.
  
* `authn_dbd_exptime`: corresponds to DBDExptime.

  Default: 300.

* `authn_dbd_keep`: Corresponds to DBDKeep.

  Default: 8.
  
* `authn_dbd_max`: Corresponds to DBDMax.

  Default: 20.

* `authn_dbd_min`: Corresponds to DBDMin.

  Default: 4.

* `authn_dbd_params`: **Required**. Corresponds to DBDParams for the connection string.

* `authn_dbd_query`: Whether to query the user and password for authentication.

##### Class: `apache::mod::authnz_ldap`

Installs `mod_authnz_ldap` and uses the `authnz_ldap.conf.erb` template to generate its configuration.

**Parameters**:

* `package_name`: The name of the package.

  Default: `undef`.
  
* `verify_server_cert`: Whether to verify the server certificate.
  
  Default: `undef`.

##### Class: `apache::mod::cluster`

**Note**: There is no official package available for `mod_cluster`, so you must make it available outside of the apache module. Binaries can be found at http://mod-cluster.jboss.org/

``` puppet
class { '::apache::mod::cluster':
  ip                      => '172.17.0.1',
  allowed_network         => '172.17.0.',
  balancer_name           => 'mycluster',
  version                 => '1.3.1'
}
```

**Parameters**:

* `port`: mod_cluster listen port.

  Default: '6666'.
  
* `server_advertise`: Whether the server should advertise.

  Default: `true`.
  
* `advertise_frequency`: Sets the interval between advertise messages in seconds[.miliseconds]. 

  Default: 10.

* `manager_allowed_network`: Whether to allow the network to access the mod_cluster_manager.

  Default: '127.0.0.1'.

* `keep_alive_timeout`: Specifies how long Apache should wait for a request, in seconds. 
  
  Default: 60.

* `max_keep_alive_requests`: Maximum number of requests kept alive.

  Default: 0.

* `enable_mcpm_receive`: Whether MCPM should be enabled.

  Default: `true`.

* `ip`: Specifies the IP address to listen to.

* `allowed_network`: Balanced members network.

* `version`: Specifies the `mod_cluster` version. Version 1.3.0 or greater is required for httpd 2.4.

##### Class: `apache::mod::deflate`

Installs and configures [`mod_deflate`][].

**Parameters**:

* `types`: An [array][] of [MIME types][MIME `content*type`] to be deflated.

  Default: [ 'text/html text/plain text/xml', 'text/css', 'application/x*javascript application/javascript application/ecmascript', 'application/rss+xml', 'application/json' ].
  
* `notes`: A [Hash][] where the key represents the type and the value represents the note name.

  Default: { 'Input'  => 'instream', 'Output' => 'outstream', 'Ratio'  => 'ratio' }.

##### Class: `apache::mod::expires`

Installs [`mod_expires`][] and uses the `expires.conf.erb` template to generate its configuration.

**Parameters**:

* `expires_active`: Enables generation of `Expires` headers for a document realm.

  Boolean. Default: `true`.

* `expires_default`: Specifies the default algorithm for calculating expiration time using [`ExpiresByType`][] syntax or [interval syntax][].

  Default: `undef`.
  
* `expires_by_type`: Describes a set of [MIME `content*type`][] and their expiration times.

  Values: An [array][] of [Hashes][Hash], with each Hash's key a valid MIME `content*type` (i.e. 'text/json') and its value following valid [interval syntax][].
  
  Default: `undef`.

##### Class: `apache::mod::ext_filter`

Installs and configures [`mod_ext_filter`][].

``` puppet
class { 'apache::mod::ext_filter':
  ext_filter_define => {
    'slowdown'       => 'mode=output cmd=/bin/cat preservescontentlength',
    'puppetdb-strip' => 'mode=output outtype=application/json cmd="pdb-resource-filter"',
  },
}
```

**Parameters**:

* `ext_filter_define`: A hash of filter names and their parameters.

  Default: `undef`.

##### Class: `apache::mod::fcgid`

Installs and configures [`mod_fcgid`][].

The class does not individually parameterize all available options. Instead, configure `mod_fcgid` using the `options` [hash][]. For example:

``` puppet
class { 'apache::mod::fcgid':
  options => {
    'FcgidIPCDir'  => '/var/run/fcgidsock',
    'SharememPath' => '/var/run/fcgid_shm',
    'AddHandler'   => 'fcgid-script .fcgi',
  },
}
```

For a full list of options, see the [official `mod_fcgid` documentation][`mod_fcgid`].

If you include `apache::mod::fcgid`, you can set the [`FcgidWrapper`][] per directory, per virtual host. The module must be loaded first; Puppet will not automatically enable it if you set the `fcgiwrapper` parameter in `apache::vhost`.

``` puppet
include apache::mod::fcgid

apache::vhost { 'example.org':
  docroot     => '/var/www/html',
  directories => {
    path        => '/var/www/html',
    fcgiwrapper => {
      command => '/usr/local/bin/fcgiwrapper',
    }
  },
}
```

##### Class: `apache::mod::geoip`

Installs and manages [`mod_geoip`][].

**Parameters**:

* `db_file`: Sets the path to your GeoIP database file.

  Values: a path, or an [array][] paths for multiple GeoIP database files.

  Default: `/usr/share/GeoIP/GeoIP.dat`.

* `enable`: Determines whether to globally enable [`mod_geoip`][].

  Boolean. Default: `false`.
  
* `flag`: Sets the GeoIP flag.

  Values: 'CheckCache', 'IndexCache', 'MemoryCache', 'Standard'.
  
  Default: 'Standard'.
  
* `output`: Defines which output variables to use.

  Values: 'All', 'Env', 'Request', 'Notes'.
  
  Default: 'All'.

* `enable_utf8`: Changes the output from ISO*8859*1 (Latin*1) to UTF*8.

  Boolean. Default: `undef`.

* `scan_proxy_headers`: Enables the [GeoIPScanProxyHeaders][] option.

  Boolean. Default: `undef`.

* `scan_proxy_header_field`: Specifies the header [`mod_geoip`][] uses to determine the client's IP address.

  Default: `undef`.

* `use_last_xforwarededfor_ip` (sic): Determines whether to use the first or last IP address for the client's IP in a comma-separated list of IP addresses is found.

  Boolean. Default: `undef`.

##### Class: `apache::mod::info`

Installs and manages [`mod_info`][], which provides a comprehensive overview of the server configuration.

**Parameters**:

* `allow_from`: Whitelist of IPv4 or IPv6 addresses or ranges that can access `/server*info`.

  Values: One or more octets of an IPv4 address, an IPv6 address or range, or an array of either.
  
  Default: ['127.0.0.1','::1'].

* `apache_version`: Apache's version number as a string, such as '2.2' or '2.4'.

  Default: The value of [`$::apache::apache_version`][`apache_version`].


* `restrict_access`: Determines whether to enable access restrictions. If `false`, the `allow_from` whitelist is ignored and any IP address can access `/server*info`.

  Boolean. Default: `true`.

##### Class: `apache::mod::passenger`

Installs and manages [`mod_passenger`][]. For Red Hat-based systems, ensure that you meet the minimum requirements described in the [passenger docs](https://www.phusionpassenger.com/library/install/apache/install/oss/el6/#step-1:-upgrade-your-kernel,-or-disable-selinux).

**Parameters**:

* `passenger_high_performance`: Sets the [`PassengerHighPerformance`](https://www.phusionpassenger.com/library/config/apache/reference/#passengerhighperformance).

  Values: 'On', 'Off'.
  
  Default: `undef`.
  
* `passenger_pool_idle_time`: Sets the [`PassengerPoolIdleTime`](https://www.phusionpassenger.com/library/config/apache/reference/#passengerpoolidletime).

  Default: `undef`.

* `passenger_max_pool_size`: Sets the [`PassengerMaxPoolSize`](https://www.phusionpassenger.com/library/config/apache/reference/#passengermaxpoolsize).

  Default: `undef`.

* `passenger_max_request_queue_size`: Sets the [`PassengerMaxRequestQueueSize`](https://www.phusionpassenger.com/library/config/apache/reference/#passengermaxrequestqueuesize).

  Default: `undef`.

* `passenger_max_requests`: Sets the [`PassengerMaxRequests`](https://www.phusionpassenger.com/library/config/apache/reference/#passengermaxrequests).

  Default: `undef`.

* `passenger_data_buffer_dir`: Sets the [`PassengerDataBufferDir`](https://www.phusionpassenger.com/library/config/apache/reference/#passengerdatabufferdir).

  Default: `undef`.

##### Class: `apache::mod::ldap`

Installs and configures [`mod_ldap`][], and allows you to modify the
[`LDAPTrustedGlobalCert`](https://httpd.apache.org/docs/current/mod/mod_ldap.html#ldaptrustedglobalcert) Directive:

``` puppet
class { 'apache::mod::ldap':
  ldap_trusted_global_cert_file => '/etc/pki/tls/certs/ldap-trust.crt',
  ldap_trusted_global_cert_type => 'CA_DER',
  ldap_shared_cache_size        => '500000',
  ldap_cache_entries            => '1024',
  ldap_cache_ttl                => '600',
  ldap_opcache_entries          => '1024',
  ldap_opcache_ttl              => '600',
}
```

**Parameters**

* `apache_version`: Specifies the installed Apache version.

  Default: `undef`.

* `ldap_trusted_global_cert_file`: Specifies the path and file name of the trusted CA certificates to use when establishing SSL or TLS connections to an LDAP server.

* `ldap_trusted_global_cert_type`: Specifies the global trust certificate format.

  Default: 'CA_BASE64'.

* `ldap_shared_cache_size`: Specifies the size, in bytes, of the shared memory cache.

* `ldap_cache_entries`: Specifies the maximum number of entries in the primary LDAP cache.

* `ldap_cache_ttl`: Specifies the time, in seconds, that cached items remain valid.

* `ldap_opcache_entries`: Specifies the number of entries used to cache LDAP compare operations.

* `ldap_opcache_ttl`: Specifies the time, in seconds, that entries in the operation cache remain valid.

* `package_name`: Specifies the custom package name.

  Default: `undef`.

##### Class: `apache::mod::negotiation`

Installs and configures [`mod_negotiation`][].

**Parameters**:

* `force_language_priority`: Sets the `ForceLanguagePriority` option.

  Values: A string.
  
  Default: `Prefer Fallback`.
  
* `language_priority`: An [array][] of languages to set the `LanguagePriority` option of the module.

  Default: [ 'en', 'ca', 'cs', 'da', 'de', 'el', 'eo', 'es', 'et', 'fr', 'he', 'hr', 'it', 'ja', 'ko', 'ltz', 'nl', 'nn', 'no', 'pl', 'pt', 'pt*BR', 'ru', 'sv', 'zh*CN', 'zh*TW' ]

##### Class: `apache::mod::nss`

An SSL provider for Apache using the NSS crypto libraries.

**Parameters:**

- `transfer_log`: path to access.log
- `error_log`: path to error.log
- `passwd_file`: path to file used for NSSPassPhraseDialog directive 
- `port`: SSL port. Defaults to 8443

##### Class: `apache::mod::pagespeed`

Installs and manages [`mod_pagespeed`][], a Google module that rewrites web pages to reduce latency and bandwidth.

Although this apache module requires the `mod-pagespeed-stable` package, Puppet **does not** manage the software repositories required to automatically install the package. If you declare this class when the package is either not installed or not available to your package manager, your Puppet run will fail.

> **Note:** Verify that your system is compatible with the latest Google Pagespeed requirements.

**Parameters**:

These parameters correspond to the module's directives. See the [module's documentation][`mod_pagespeed`] for details.

* `inherit_vhost_config`: Default: 'on'.
* `filter_xhtml`: Default: `false`.
* `cache_path`: Default: '/var/cache/mod_pagespeed/'.
* `log_dir`: Default: '/var/log/pagespeed'.
* `memcache_servers`: Default: [].
* `rewrite_level`: Default: 'CoreFilters'.
* `disable_filters`: Default: [].
* `enable_filters`: Default: [].
* `forbid_filters`: Default: [].
* `rewrite_deadline_per_flush_ms`: Default: 10.
* `additional_domains`: Default: `undef`.
* `file_cache_size_kb`: Default: 102400.
* `file_cache_clean_interval_ms`: Default: 3600000.
* `lru_cache_per_process`: Default: 1024.
* `lru_cache_byte_limit`: Default: 16384.
* `css_flatten_max_bytes`: Default: 2048.
* `css_inline_max_bytes`: Default: 2048.
* `css_image_inline_max_bytes`: Default: 2048.
* `image_inline_max_bytes`: Default: 2048.
* `js_inline_max_bytes`: Default: 2048.
* `css_outline_min_bytes`: Default: 3000.
* `js_outline_min_bytes`: Default: 3000.
* `inode_limit`: Default: 500000.
* `image_max_rewrites_at_once`: Default: 8.
* `num_rewrite_threads`: Default: 4.
* `num_expensive_rewrite_threads`: Default: 4.
* `collect_statistics`: Default: 'on'.
* `statistics_logging`: Default: 'on'.
* `allow_view_stats`: Default: [].
* `allow_pagespeed_console`: Default: [].
* `allow_pagespeed_message`: Default: [].
* `message_buffer_size`: Default: 100000.
* `additional_configuration`: A hash of directive value pairs, or an array of lines to insert at the end of the pagespeed configuration. Default: '{ }'.

##### Class: `apache::mod::passenger`

Installs and configures `mod_passenger`.

>**Note**: The passenger module isn't available on RH/CentOS without providing the dependency packages provided by EPEL and the `mod_passengers` custom repository. See the `manage_repo` parameter above and [https://www.phusionpassenger.com/library/install/apache/install/oss/el7/]()

**Parameters**: [TODO: parameters were not listed (except `manage_repo`), so I pulled them out of the manifest. I need to know what these parameters do and what their values can be OR a link that points external documentation for the parameter mapping (as with mod_pagespeed above) <!--see also MODULES-4745-->]

* `passenger_conf_file`: `$::apache::params::passenger_conf_file`
* `passenger_conf_package_file: `$::apache::params::passenger_conf_package_file`
* `passenger_high_performance`: Default: `undef`
* `passenger_pool_idle_time`: Default: `undef`
* `passenger_max_request_queue_size`: Default: `undef`
* `passenger_max_requests`: Default: `undef`
* `passenger_spawn_method`: Default: `undef`
* `passenger_stat_throttle_rate`: Default: `undef`
* `rack_autodetect`: Default: `undef`
* `rails_autodetect`: Default: `undef`
* `passenger_root` : `$::apache::params::passenger_root`
* `passenger_ruby` : `$::apache::params::passenger_ruby`
* `passenger_default_ruby`: `$::apache::params::passenger_default_ruby`
* `passenger_max_pool_size`: Default: `undef`
* `passenger_min_instances`: Default: `undef`
* `passenger_max_instances_per_app`: Default: `undef`
* `passenger_use_global_queue`: Default: `undef`
* `passenger_app_env`: Default: `undef`
* `passenger_log_file`: Default: `undef`
* `passenger_log_level`: Default: `undef`
* `passenger_data_buffer_dir`: Default: `undef`
* `manage_repo`: Whether to manage the phusionpassenger.com repository. Default: `true`.
* `mod_package`: Default: `undef`.
* `mod_package_ensure`: Default: `undef`.
* `mod_lib`: Default: `undef`.
* `mod_lib_path`: Default: `undef`.
* `mod_id`: Default: `undef`.
* `mod_path`: Default: `undef`.

##### Class: `apache::mod::proxy`

Installs `mod_proxy` and uses the `proxy.conf.erb` template to generate its configuration.

**Parameters within `apache::mod::proxy`**:

TODO: What do these parameters do?

- `allow_from`: Default: `undef`.
- `apache_version`: Default: `undef`.
- `package_name`: Default: `undef`.
- `proxy_requests`: Default: 'Off'.
- `proxy_via`: Default: 'On'.

##### Class: `apache::mod::proxy_balancer`

Installs and manages [`mod_proxy_balancer`][], which provides load balancing.

**Parameters**:

* `manager`: Determines whether to enable balancer manager support.

  Default: `false`.
  
* `manager_path`: The server location of the balancer manager.

  Default: '/balancer*manager'.
  
* `allow_from`: An [array][] of IPv4 or IPv6 addresses that can access `/balancer*manager`.

  Default: ['127.0.0.1','::1'].
  
* `apache_version`: Apache's version number as a string, such as '2.2' or '2.4'.

  Default: the value of [`$::apache::apache_version`][`apache_version`]. On Apache 2.4 or greater, `mod_slotmem_shm` is loaded.

##### Class: `apache::mod::php`

Installs and configures [`mod_php`][].

**Parameters**:

Default values for these parameters depend on your operating system. Most of this class's parameters correspond to `mod_php` directives; see the [module's documentation][`mod_php`] for details.

* `package_name`: Names the package that installs `mod_php`.
* `path`: Defines the path to the `mod_php` shared object (`.so`) file.
* `source`: Defines the path to the default configuration. Values include a `puppet:///` path.
* `template`: Defines the path to the `php.conf` template Puppet uses to generate the configuration file.
* `content`: Adds arbitrary content to `php.conf`.

##### Class: `apache::mod::proxy_html`

**Note**: There is no official package available for `mod_proxy_html`, so you must make it available outside of the apache module. 

##### Class: `apache::mod::reqtimeout`

Installs and configures [`mod_reqtimeout`][].

**Parameters**

* `timeouts`: Sets the [`RequestReadTimeout`][] option. 

  Values:  A string or [array][].
  
  Default: ['header=20-40,MinRate=500', 'body=20,MinRate=500'].

##### Class: `apache::mod::rewrite`

Installs and enables the Apache module `mod_rewrite`.

##### Class: `apache::mod::shib`

Installs the [Shibboleth](http://shibboleth.net/) Apache module `mod_shib`, which enables SAML2 single sign-on (SSO) authentication by Shibboleth Identity Providers and Shibboleth Federations. Defining this class enables Shibboleth-specific parameters in `apache::vhost` instances.

This class installs and configures only the Apache components of a web application that consumes Shibboleth SSO identities. You can manage the Shibboleth configuration manually, with Puppet, or using a [Shibboleth Puppet Module](https://github.com/aethylred/puppet-shibboleth).

**Note**: The shibboleth module isn't available on RH/CentOS without providing dependency packages provided by Shibboleth's repositories. See [http://wiki.aaf.edu.au/tech-info/sp-install-guide]()

##### Class: `apache::mod::ssl`

Installs [Apache SSL features][`mod_ssl`] and uses the `ssl.conf.erb` template to generate its configuration. On most operating systems, this `ssl.conf` is placed in the module configuration directory. On Red Hat-based operating systems, this file is placed in `/etc/httpd/conf.d`, the same location in which the RPM stores the configuration.

To use SSL with a virtual host, you must either set the [`default_ssl_vhost`][] parameter in `::apache` to `true` **or** the [`ssl`][] parameter in [`apache::vhost`][] to `true`.

- `ssl_cipher`: Default: 'HIGH:MEDIUM:!aNULL:!MD5:!RC4'.
- `ssl_compression`: Default: false.
- `ssl_cryptodevice`: Default: 'builtin'.
- `ssl_honorcipherorder`: Default: true.
- `ssl_openssl_conf_cmd`: Default: undef.
- `ssl_options`: Default: [ 'StdEnvVars' ]
- `ssl_pass_phrase_dialog`: Default: 'builtin'.
- `ssl_protocol`: Default: [ 'all', '-SSLv2', '-SSLv3' ].
- `ssl_proxy_protocol`: Default: [].
- `ssl_random_seed_bytes`: Valid options: A string. Default: '512'.
- `ssl_sessioncache`: Valid options: A string. Default: '300'.
- `ssl_sessioncachetimeout`: Valid options: A string. Default: '300'.
- `ssl_mutex`: Default: Determined based on the OS. Valid options: See [mod_ssl][mod_ssl] documentation.
  - RedHat/FreeBSD/Suse/Gentoo: 'default'
  - Debian/Ubuntu + Apache >= 2.4: 'default'
  - Debian/Ubuntu + Apache < 2.4: 'file:\${APACHE_RUN_DIR}/ssl_mutex'
**Parameters:

* `ssl_cipher`

  Default: 'HIGH:MEDIUM:!aNULL:!MD5:!RC4'.

* `ssl_compression`

  Default: `false`.

* `ssl_cryptodevice`

  Default: 'builtin'.

* `ssl_honorcipherorder`

  Default: `true`.
  
* `ssl_openssl_conf_cmd`

  Default: `undef`.

* `ssl_options`

  Default: [ 'StdEnvVars' ]

* `ssl_pass_phrase_dialog`

  Default: 'builtin'.

* `ssl_protocol`

  Default: [ 'all', '*SSLv2', '*SSLv3' ].
  
* `ssl_random_seed_bytes`

  Values: A string.
  
  Default: '512'.
  
* `ssl_sessioncachetimeout`

  Values: A string.
  
  Default: '300'.
  
* `ssl_mutex`:

  Values: See [mod_ssl][mod_ssl] documentation.

  Default: Based on the OS:
 
  * RedHat/FreeBSD/Suse/Gentoo: 'default'.
  * Debian/Ubuntu + Apache >= 2.4: 'default'.
  * Debian/Ubuntu + Apache < 2.4: 'file:\${APACHE_RUN_DIR}/ssl_mutex'.
  * Ubuntu 10.04: 'file:/var/run/apache2/ssl_mutex'.


##### Class: `apache::mod::status`

Installs [`mod_status`][] and uses the `status.conf.erb` template to generate its configuration.

**Parameters**:

* `allow_from`: An [array][] of IPv4 or IPv6 addresses that can access `/server-status`. 

  Default: ['127.0.0.1','::1'].
* `extended_status`: Determines whether to track extended status information for each request, via the [`ExtendedStatus`][] directive.

  Values: 'Off', 'On'.
  
  Default: 'On'.
  
* `status_path`: The server location of the status page.

  Default: '/server-status'.

##### Class: `apache::mod::version`

Installs [`mod_version`][] on many operating systems and Apache configurations.

If Debian and Ubuntu systems with Apache 2.4 are classified with `apache::mod::version`, Puppet warns that `mod_version` is built-in and can't be loaded.

##### Class: `apache::mod::security`

Installs and configures Trustwave's [`mod_security`][]. It is enabled and runs by default on all virtual hosts.

**Parameters**:

* `activated_rules`: An [array][] of rules from the `modsec_crs_path` or absolute to activate via symlinks.
* `allowed_methods`: A space*separated list of allowed HTTP methods.

  Default: 'GET HEAD POST OPTIONS'.

* `content_types`: A list of one or more allowed [MIME types][MIME `content*type`]. 

  Default: 'application/x*www*form*urlencoded|multipart/form*data|text/xml|application/xml|application/x*amf'.

* `crs_package`: Names the package that installs CRS rules.

  Default: `modsec_crs_package` in [`apache::params`][].

* `manage_security_crs`: Manage security_crs.conf rules file.

  Default: `true`.
  
* `modsec_dir`: Defines the path where Puppet installs the modsec configuration and activated rules links.

  Default: 'On', set by `modsec_dir` in [`apache::params`][].
${modsec\_dir}/activated\_rules.

* `modsec_secruleengine`: Configures the modsec rules engine. Values: 'On', 'Off', and 'DetectionOnly'.

  Default: `modsec_secruleengine` in [`apache::params`][].

* `restricted_extensions`: A space*separated list of prohibited file extensions.

  Default: '.asa/ .asax/ .ascx/ .axd/ .backup/ .bak/ .bat/ .cdx/ .cer/ .cfg/ .cmd/ .com/ .config/ .conf/ .cs/ .csproj/ .csr/ .dat/ .db/ .dbf/ .dll/ .dos/ .htr/ .htw/ .ida/ .idc/ .idq/ .inc/ .ini/ .key/ .licx/ .lnk/ .log/ .mdb/ .old/ .pass/ .pdb/ .pol/ .printer/ .pwd/ .resources/ .resx/ .sql/ .sys/ .vb/ .vbs/ .vbproj/ .vsdisco/ .webinfo/ .xsd/ .xsx/'.

* `restricted_headers`: A list of restricted headers separated by slashes and spaces. 

  Default: 'Proxy*Connection/ /Lock*Token/ /Content*Range/ /Translate/ /via/ /if/'.

* `secdefaultaction`: Configures the Mode of Operation, Self-Contained ('deny') or Collaborative Detection ('pass'), for the OWASP ModSecurity Core Rule Set.

  Default: 'deny'. You can also set full values, such as "log,auditlog,deny,status:406,tag:'SLA 24/7'".

* `secpcrematchlimit`: Sets the number for the match limit in the PCRE library.

  Default: 1500.

* `secpcrematchlimitrecursion`: Sets the number for the match limit recursion in the PCRE library.

  Default: 1500.

* `logroot`: Configures the location of audit and debug logs.

  Defaults to the Apache log directory (Redhat: `/var/log/httpd`,  Debian: `/var/log/apache2`).

* `audit_log_releavant_status`: Configures which response status code is to be considered relevant for the purpose of audit logging.

  Default: '^(?:5|4(?!04))'.

* `audit_log_parts`: Sets the sections to be put in the [audit log][].

  Default: 'ABIJDEFHZ'.
  
* `anomaly_score_blocking`: Activates or deactivates the Collaborative Detection Blocking of the OWASP ModSecurity Core Rule Set.

  Default: 'off'.
  
* `inbound_anomaly_threshold`: Sets the scoring threshold level of the inbound blocking rules for the Collaborative Detection Mode in the OWASP ModSecurity Core Rule Set.

  Default: 5.
  
* `outbound_anomaly_threshold`: Sets the scoring threshold level of the outbound blocking rules for the Collaborative Detection Mode in the OWASP ModSecurity Core Rule Set.

  Default: 4.
  
* `critical_anomaly_score`: Sets the scoring points of the critical severity level for the Collaborative Detection Mode in the OWASP ModSecurity Core Rule Set.

  Default: 5.
  
* `error_anomaly_score`: Sets the scoring points of the error severity level for the Collaborative Detection Mode in the OWASP ModSecurity Core Rule Set.

  Default: 4.
  
* `warning_anomaly_score`: Sets the scoring points of the warning severity level for the Collaborative Detection Mode in the OWASP ModSecurity Core Rule Set.

  Default: 3.

* `notice_anomaly_score`: Sets the scoring points of the notice severity level for the Collaborative Detection Mode in the OWASP ModSecurity Core Rule Set.

Default: 2.

* `secrequestmaxnumargs`: Sets the Maximum number of arguments in the request.

  Default: 255.

* `secrequestbodylimit`:  Sets the maximum request body size ModSecurity accepts for buffering.

  Default: '13107200'.
  
* `secrequestbodynofileslimit`: Sets the maximum request body size ModSecurity accepts for buffering, excluding the size of any files being transported in the request.

  Default: '131072'.
  
* `secrequestbodyinmemorylimit`: Sets the maximum request body size that ModSecurity stores in memory.

  Default: '131072'

##### Class: `apache::mod::wsgi`

Enables Python support via [`mod_wsgi`][].

**Parameters**:

* `mod_path`: Defines the path to the `mod_wsgi` shared object (`.so`) file.

  Default: `undef`.
  
  * If the `mod_path` parameter doesn't contain `/`, Puppet prefixes it with your operating system's default module path. Otherwise, Puppet follows it literally.
  
* `package_name`: Names the package that installs `mod_wsgi`.

  Default: `undef`.

* `wsgi_python_home`: Defines the [`WSGIPythonHome`][] directive, such as '/path/to/venv'. 

  Values: A string specifying a path.

  Default: `undef`.
  
* `wsgi_python_path`: Defines the [`WSGIPythonPath`][] directive, such as '/path/to/venv/site*packages'.

  Values: A string specifying a path.
  
  Default: `undef`.

* `wsgi_restrict_embedded`: Defines the [`WSGIRestrictEmbedded`][] directive, such as 'On'. 

Values: On|Off|undef.

Default: undef.

* `wsgi_socket_prefix`: Defines the [`WSGISocketPrefix`][] directive, such as "\${APACHE\_RUN\_DIR}WSGI".

  Default: `wsgi_socket_prefix` in [`apache::params`][].

The class's parameters correspond to the module's directives. See the [module's documentation][`mod_wsgi`] for details.

### Private Classes

#### Class: `apache::confd::no_accf`

Creates the `no-accf.conf` configuration file in `conf.d`, required by FreeBSD's Apache 2.4.

#### Class: `apache::default_confd_files`

Includes `conf.d` files for FreeBSD.

#### Class: `apache::default_mods`

Installs the Apache modules required to run the default configuration. See the `apache` class's [`default_mods`][] parameter for details.

#### Class: `apache::package`

Installs and configures basic Apache packages.

#### Class: `apache::params`

Manages Apache parameters for different operating systems.

#### Class: `apache::service`

Manages the Apache daemon.

#### Class: `apache::version`

Attempts to automatically detect the Apache version based on the operating system.

### Public defined types

#### Defined type: `apache::balancer`

Creates an Apache load balancing group, also known as a balancer cluster, using [`mod_proxy`][]. Each load balancing group needs one or more balancer members, which you can declare in Puppet with the  [`apache::balancermember`][] defined type.

Declare one `apache::balancer` defined type for each Apache load balancing group. You can export `apache::balancermember` defined types for all balancer members and collect them on a single Apache load balancer server using [exported resources][].

**Parameters**:

##### `name`

Sets the title of the balancer cluster and name of the `conf.d` file containing its configuration.

##### `proxy_set`

Configures key-value pairs as [`ProxySet`][] lines. Values: a [hash][]. Default: '{}'.

##### `collect_exported`

Determines whether to use [exported resources][].

If you statically declare all of your backend servers, set this parameter to `false` to rely on existing, declared balancer member resources. Also, use `apache::balancermember` with [array][] arguments.

To dynamically declare backend servers via exported resources collected on a central node, set this parameter to `true` to collect the balancer member resources exported by the balancer member nodes.

If you don't use exported resources, a single Puppet run configures all balancer members. If you use exported resources, Puppet has to run on the balanced nodes first, then run on the balancer.

Boolean. Default: `true`.

#### Defined type: `apache::balancermember`

Defines members of [`mod_proxy_balancer`][], which sets up a balancer member inside a listening service configuration block in the load balancer's `apache.cfg`.

**Parameters**:

##### `balancer_cluster`

**Required**.

Sets the Apache service's instance name, and must match the name of a declared [`apache::balancer`][] resource.

##### `url`

Specifies the URL used to contact the balancer member server.

Default: 'http://${::fqdn}/'.

##### `options`

Specifies an [array][] of [options](https://httpd.apache.org/docs/current/mod/mod_proxy.html#balancermember) after the URL, and accepts any key-value pairs available to [`ProxyPass`][].

Default: an empty array.

#### Defined type: `apache::custom_config`

Adds a custom configuration file to the Apache server's `conf.d` directory. If the file is invalid and this defined type's [`verify_config`][] parameter's value is `true`, Puppet throws an error during a Puppet run.

**Parameters**:

##### `ensure`

Specifies whether the configuration file should be present.

Values: 'absent', 'present'.

Default: 'present'.

##### `confdir`

Sets the directory in which Puppet places configuration files.

Default: the value of [`$::apache::confd_dir`][`confd_dir`].

##### `content`

Sets the configuration file's content. The `content` and [`source`][] parameters are exclusive of each other.

Default: `undef`

##### `filename`

Sets the name of the file under `confdir` in which Puppet stores the configuration.

Default: Filename generated from the `priority` parameter and the resource name.

##### `priority`

Sets the configuration file's priority by prefixing its filename with this parameter's numeric value, as Apache processes configuration files in alphanumeric order.

To omit the priority prefix in the configuration file's name, set this parameter to `false`.

Default: '25'.

##### `source`

Points to the configuration file's source. The [`content`][] and `source` parameters are exclusive of each other. TODO: is this required or does it have a default value?

Default: `undef`

##### `verify_command`

Specifies the command Puppet uses to verify the configuration file. Use a fully qualified command.

This parameter is used only if the [`verify_config`][] parameter's value is `true`. If the `verify_command` fails, the Puppet run deletes the configuration file and raises an error, but does not notify the Apache service.

Default: '/usr/sbin/apachectl -t'.

##### `verify_config`

Specifies whether to validate the configuration file before notifying the Apache service.

Boolean. Default: `true`.

#### Defined type: `apache::fastcgi::server`

Defines one or more external FastCGI servers to handle specific file types. Use this defined type with [`mod_fastcgi`][FastCGI].

**Parameters**

##### `host`

Determines the FastCGI's hostname or IP address and TCP port number (1-65535).

Default: '127.0.0.1:9000'.

##### `timeout`

Sets the number of seconds a [FastCGI][] application can be inactive before aborting the request and logging the event at the error LogLevel. The inactivity timer applies only as long as a connection is pending with the FastCGI application. If a request is queued to an application, but the application doesn't respond by writing and flushing within this period, the request is aborted. If communication is complete with the application but incomplete with the client (the response is buffered), the timeout does not apply.

Default: 15.

##### `flush`

Forces [`mod_fastcgi`][FastCGI] to write to the client as data is received from the application. By default, `mod_fastcgi` buffers data in order to free the application as quickly as possible.

Default: `false`.

##### `faux_path`

Apache has [FastCGI][] handle URIs that resolve to this filename. The path set in this parameter does not have to exist in the local filesystem.

Default: "/var/www/${name}.fcgi".

##### `alias`

Internally links actions with the FastCGI server. This alias must be unique.

Default: "/${name}.fcgi".

##### `file_type`

Sets the [MIME `content-type`][] of the file to be processed by the FastCGI server.

Default: 'application/x-httpd-php'.

#### Defined type: `apache::listen`

Adds [`Listen`][] directives to `ports.conf` in the Apache configuration directory that define the Apache server's or a virtual host's listening address and port. The [`apache::vhost`][] class uses this defined type, and titles take the form `<PORT>`, `<IPV4>:<PORT>`, or `<IPV6>:<PORT>`.

#### Defined type: `apache::mod`

Installs packages for an Apache module that doesn't have a corresponding [`apache::mod::<MODULE NAME>`][] class, and checks for or places the module's default configuration files in the Apache server's `module` and `enable` directories. The default locations depend on your operating system.

**Parameters**:

##### `package`

**Required**.

Names the package Puppet uses to install the Apache module.

Default: `undef`.

##### `package_ensure`

Determines whether Puppet ensures the Apache module should be installed.

Values: 'absent', 'present'.

Default: 'present'.

##### `lib`

Defines the module's shared object name. Do not configure manually without special reason.

Default: `mod_$name.so`.

##### `lib_path`

Specifies a path to the module's libraries. Do not manually set this parameter without special reason. The [`path`][] parameter overrides this value.

Default: The `apache` class's [`lib_path`][] parameter.


##### `loadfile_name`

Sets the filename for the module's [`LoadFile`][] directive, which can also set the module load order as Apache processes them in alphanumeric order.

Values: Filenames formatted `\*.load`.

Default: the resource's name followed by 'load', as in '$name.load'.

##### `loadfiles`

Specifies an array of [`LoadFile`][] directives.

Default: `undef`.

##### `path`

Specifies a path to the module. Do not manually set this parameter without a special reason.

Default: [`lib_path`][]/[`lib`][].

#### Defined type: `apache::namevirtualhost`

Enables [name-based virtual hosts][] and adds all related directives to the `ports.conf` file in the Apache HTTPD configuration directory. Titles can take the forms '\*', '\*:\<PORT\>', '\_default\_:\<PORT\>, '\<IP\>', or '\<IP\>:\<PORT\>'.

#### Defined type: `apache::vhost`

The apache module allows a lot of flexibility in the setup and configuration of virtual hosts. This flexibility is due, in part, to `vhost` being a defined resource type, which allows Apache to evaluate it multiple times with different parameters.

The `apache::vhost` defined type allows you to have specialized configurations for virtual hosts that have requirements outside the defaults. You can set up a default virtual host within the base `::apache` class, as well as set a customized virtual host as the default. Customized virtual hosts have a lower numeric [`priority`][] than the base class's, causing Apache to process the customized virtual host first.

The `apache::vhost` defined type uses `concat::fragment` to build the configuration file. To inject custom fragments for pieces of the configuration that the defined type doesn't inherently support, add a custom fragment.

For the custom fragment's `order` parameter, the `apache::vhost` defined type uses multiples of 10, so any `order` that isn't a multiple of 10 should work.

**Parameters**:

##### `access_log`

Determines whether to configure `*_access.log` directives (`*_file`,`*_pipe`, or `*_syslog`). 

Boolean. Default: `true`.

##### `access_log_env_var`

Specifies that only requests with particular environment variables be logged.

Default: `undef`.

##### `access_log_file`

Sets the filename of the `*_access.log` placed in [`logroot`][]. Given a virtual host---for instance, example.com---it defaults to 'example.com_ssl.log' for [SSL-encrypted][SSL encryption] virtual hosts and 'example.com_access.log' for unencrypted virtual hosts.

Default: `false`.

##### `access_log_format`

Specifies the use of either a [`LogFormat`][] nickname or a custom-formatted string for the access log.

Default: 'combined'.

##### `access_log_pipe`

Specifies a pipe where Apache sends access log messages.

Default: `undef`.

##### `access_log_syslog`

Sends all access log messages to syslog.

Default: `undef`.

##### `add_default_charset`

Sets a default media charset value for the [`AddDefaultCharset`][] directive, which is added to `text/plain` and `text/html` responses.

Default: `undef`.

##### `add_listen`

Determines whether the virtual host creates a [`Listen`][] statement.

Setting `add_listen` to `false` prevents the virtual host from creating a `Listen` statement. This is important when combining virtual hosts that aren't passed an `ip` parameter with those that are.

Boolean. Default: `true`.

##### `use_optional_includes`

Specifies whether Apache uses the [`IncludeOptional`][] directive instead of [`Include`][] for `additional_includes` in Apache 2.4 or newer.

Boolean. Default: `false`.

##### `additional_includes`

Specifies paths to additional static, virtual host-specific Apache configuration files. You can use this parameter to implement a unique, custom configuration not supported by this module.

Values: a string or [array][] of strings specifying paths.

Default: an empty array.

##### `aliases`

Passes a list of [hashes][hash] to the virtual host to create [`Alias`][], [`AliasMatch`][], [`ScriptAlias`][] or [`ScriptAliasMatch`][] directives as per the [`mod_alias`][] documentation.

For example:

``` puppet
aliases => [
  { aliasmatch       => '^/image/(.*)\.jpg$',
    path             => '/files/jpg.images/$1.jpg',
  },
  { alias            => '/image',
    path             => '/ftp/pub/image',
  },
  { scriptaliasmatch => '^/cgi-bin(.*)',
    path             => '/usr/local/share/cgi-bin$1',
  },
  { scriptalias      => '/nagios/cgi-bin/',
    path             => '/usr/lib/nagios/cgi-bin/',
  },
  { alias            => '/nagios',
    path             => '/usr/share/nagios/html',
  },
],
```

For the `alias`, `aliasmatch`, `scriptalias` and `scriptaliasmatch` keys to work, each needs a corresponding context, such as `<Directory /path/to/directory>` or `<Location /some/location/here>`. Puppet creates the directives in the order specified in the `aliases` parameter. As described in the [`mod_alias`][] documentation, add more specific `alias`, `aliasmatch`, `scriptalias` or `scriptaliasmatch` parameters before the more general ones to avoid shadowing.

> **Note**: Use the `aliases` parameter instead of the `scriptaliases` parameter because you can precisely control the order of various alias directives. Defining `ScriptAliases` using the `scriptaliases` parameter means *all* `ScriptAlias` directives will come after *all* `Alias` directives, which can lead to `Alias` directives shadowing `ScriptAlias` directives. This often causes problems; for example, this could cause problems with Nagios.

If [`apache::mod::passenger`][] is loaded and `PassengerHighPerformance` is `true`, the `Alias` directive might not be able to honor the `PassengerEnabled => off` statement. See [this article](http://www.conandalton.net/2010/06/passengerenabled-off-not-working.html) for details.

##### `allow_encoded_slashes`

Sets the [`AllowEncodedSlashes`][] declaration for the virtual host, overriding the server default. This modifies the virtual host responses to URLs with `\` and `/` characters. Values: 'nodecode', 'off', 'on'. The default setting omits the declaration from the server configuration and selects the Apache default setting of 'Off'.

Default: `undef`

##### `block`

Specifies the list of things to which Apache blocks access. Valid option: 'scm', which blocks web access to `.svn`, `.git`, and `.bzr` directories.

Default: an empty [array][].

##### `cas_attribute_prefix`

Adds a header with the value of this header being the attribute values when SAML validation is enabled.

Defaults: The value set by [`apache::mod::auth_cas`][].

##### `cas_attribute_delimiter`

Sets the delimiter between attribute values in the header created by `cas_attribute_prefix`.

Default: The value set by [`apache::mod::auth_cas`][].

##### `cas_login_url`

Sets the URL to which the module redirects users when they attempt to access a CAS-protected resource and
don't have an active session.

Default: The value set by [`apache::mod::auth_cas`][].

##### `cas_scrub_request_headers`

Remove inbound request headers that may have special meaning within mod_auth_cas.

Default: The value set by [`apache::mod::auth_cas`][].

##### `cas_sso_enabled`

Enables experimental support for single sign out (may mangle POST data).

Default: The value set by [`apache::mod::auth_cas`][].

##### `cas_validate_saml`

Parse response from CAS server for SAML. Default: The value set by [`apache::mod::auth_cas`][].

##### `cas_validate_url`

Sets the URL to use when validating a client-presented ticket in an HTTP query string. 

Defaults to the value set by [`apache::mod::auth_cas`][].

##### `custom_fragment`

Passes a string of custom configuration directives to place at the end of the virtual host configuration.

Default: `undef`.

##### `default_vhost`

Sets a given `apache::vhost` defined type as the default to serve requests that do not match any other `apache::vhost` defined types.

Default: `false`.

##### `directories`

See the [`directories`](#parameter-directories-for-apachevhost) section.

##### `directoryindex`

Sets the list of resources to look for when a client requests an index of the directory by specifying a '/' at the end of the directory name. See the [`DirectoryIndex`][] directive documentation for details.

Default: `undef`.

##### `docroot`

**Required**.

Sets the [`DocumentRoot`][] location, from which Apache serves files.

If `docroot` and [`manage_docroot`][] are both set to `false`, no [`DocumentRoot`][] will be set and the accompanying `<Directory /path/to/directory>` block will not be created.

Values: A string specifying a directory path.

##### `docroot_group`

Sets group access to the [`docroot`][] directory.

Values: A string specifying a system group.

Default: 'root'.

##### `docroot_owner`

Sets individual user access to the [`docroot`][] directory.

Values: A string specifying a user account.

Default: 'root'.

##### `docroot_mode`

Sets access permissions for the [`docroot`][] directory, in numeric notation.

Values: A string.

Default: `undef`.

##### `manage_docroot`

Determines whether Puppet manages the [`docroot`][] directory.

Boolean. Default: `true`.

##### `error_log`

Specifies whether `*_error.log` directives should be configured.

Boolean. Default: `true`.

##### `error_log_file`

Points the virtual host's error logs to a `*_error.log` file. If this parameter is undefined, Puppet checks for values in [`error_log_pipe`][], then [`error_log_syslog`][].

If none of these parameters is set, given a virtual host `example.com`, Puppet defaults to '$logroot/example.com_error_ssl.log' for SSL virtual hosts and '$logroot/example.com_error.log' for non-SSL virtual hosts.

Default: `undef`.

##### `error_log_pipe`

Specifies a pipe to send error log messages to.

This parameter has no effect if the [`error_log_file`][] parameter has a value. If neither this parameter nor `error_log_file` has a value, Puppet then checks [`error_log_syslog`][].

Default: `undef`.

##### `error_log_syslog`

Determines whether to send all error log messages to syslog.

This parameter has no effect if either of the [`error_log_file`][] or [`error_log_pipe`][] parameters has a value. If none of these parameters has a value, given a virtual host `example.com`, Puppet defaults to '$logroot/example.com_error_ssl.log' for SSL virtual hosts and '$logroot/example.com_error.log' for non-SSL virtual hosts.

Boolean. Default: `undef`.

##### `error_documents`

A list of hashes which can be used to override the [ErrorDocument](https://httpd.apache.org/docs/current/mod/core.html#errordocument) settings for this virtual host.

For example:

``` puppet
apache::vhost { 'sample.example.net':
  error_documents => [
    { 'error_code' => '503', 'document' => '/service-unavail' },
    { 'error_code' => '407', 'document' => 'https://example.com/proxy/login' },
  ],
}
```

Default: '[]'.

##### `ensure`

Specifies if the virtual host is present or absent.

Values: 'absent', 'present'.

Default: 'present'.

##### `fallbackresource`

Sets the [FallbackResource](https://httpd.apache.org/docs/current/mod/mod_dir.html#fallbackresource) directive, which specifies an action to take for any URL that doesn't map to anything in your filesystem and would otherwise return 'HTTP 404 (Not Found)'. Values must either begin with a '/' or be 'disabled'.

Default: `undef`.

#####`fastcgi_idle_timeout`

If using fastcgi, this option sets the timeout for the server to respond.

Default: `undef`.

##### `file_e_tag`

Sets the server default for the [`FileETag`][] declaration, which modifies the response header field for static files.

Values: 'INode', 'MTime', 'Size', 'All', 'None'. 

Default: `undef`, which uses Apache's default setting of 'MTime Size'.

##### `filters`

[Filters](https://httpd.apache.org/docs/current/mod/mod_filter.html) enable smart, context-sensitive configuration of output content filters.

``` puppet
apache::vhost { "$::fqdn":
  filters => [
    'FilterDeclare   COMPRESS',
    'FilterProvider  COMPRESS DEFLATE resp=Content-Type $text/html',
    'FilterChain     COMPRESS',
    'FilterProtocol  COMPRESS DEFLATE change=yes;byteranges=no',
  ],
}
```

##### `force_type`

Sets the [`ForceType`][] directive, which forces Apache to serve all matching files with a [MIME `content-type`][] matching this parameter's value.

#### `add_charset`

Lets Apache set custom content character sets per directory and/or file extension

##### `headers`

Adds lines to replace, merge, or remove response headers. See [Apache's mod_headers documentation](https://httpd.apache.org/docs/current/mod/mod_headers.html#header) for more information.

Values: A string or an array of strings.

Default: `undef`.

##### `ip`

Sets the IP address the virtual host listens on. By default, uses Apache's default behavior of listening on all IPs.

Values: A string or an array of strings.

Default: `undef`. 

##### `ip_based`

Enables an [IP-based](https://httpd.apache.org/docs/current/vhosts/ip-based.html) virtual host. This parameter inhibits the creation of a NameVirtualHost directive, since those are used to funnel requests to name-based virtual hosts.

Default: `false`.

##### `itk`

Configures [ITK](http://mpm-itk.sesse.net/) in a hash.

Usage typically looks something like:

``` puppet
apache::vhost { 'sample.example.net':
  docroot => '/path/to/directory',
  itk     => {
    user  => 'someuser',
    group => 'somegroup',
  },
}
```

Values: a hash, which can include the keys:

* user + group
* `assignuseridexpr`
* `assigngroupidexpr`
* `maxclientvhost`
* `nice`
* `limituidrange` (Linux 3.5.0 or newer)
* `limitgidrange` (Linux 3.5.0 or newer)

Usage typically looks like:

``` puppet
apache::vhost { 'sample.example.net':
  docroot => '/path/to/directory',
  itk     => {
    user  => 'someuser',
    group => 'somegroup',
  },
}
```

Default: `undef`.

##### `jk_mounts`

Sets up a virtual host with 'JkMount' and 'JkUnMount' directives to handle the paths for URL mapping between Tomcat and Apache.

The parameter must be an array of hashes where each hash must contain the 'worker' and either the 'mount' or 'unmount' keys.

Usage typically looks like:

``` puppet
apache::vhost { 'sample.example.net':
  jk_mounts => [
    { mount   => '/*',     worker => 'tcnode1', },
    { unmount => '/*.jpg', worker => 'tcnode1', },
  ],
}
```
Default: `undef`.
 
##### `keepalive`

Determines whether to enable persistent HTTP connections with the [`KeepAlive`][] directive for the virtual host. By default, the global, server-wide [`KeepAlive`][] setting is in effect.

Use the `keepalive_timeout` and `max_keepalive_requests` parameters to set relevant options for the virtual host.

Values: 'Off', 'On'.

Default: `undef`

##### `keepalive_timeout`

Sets the [`KeepAliveTimeout`] directive for the virtual host, which determines the amount of time to wait for subsequent requests on a persistent HTTP connection. By default, the global, server-wide [`KeepAlive`][] setting is in effect.

This parameter is only relevant if either the global, server-wide [`keepalive` parameter][] or the per-vhost `keepalive` parameter is enabled.

Default: `undef`

##### `max_keepalive_requests`

Limits the number of requests allowed per connection to the virtual host. By default,  the global, server-wide [`KeepAlive`][] setting is in effect.

This parameter is only relevant if either the global, server-wide [`keepalive` parameter][] or the per-vhost `keepalive` parameter is enabled.

Default: `undef`.

##### `auth_kerb`

Enable [`mod_auth_kerb`][] parameters for a virtual host. 

Usage typically looks like:

``` puppet
apache::vhost { 'sample.example.net':
  auth_kerb              => `true`,
  krb_method_negotiate   => 'on',
  krb_auth_realms        => ['EXAMPLE.ORG'],
  krb_local_user_mapping => 'on',
  directories            => {
    path         => '/var/www/html',
    auth_name    => 'Kerberos Login',
    auth_type    => 'Kerberos',
    auth_require => 'valid-user',
  },
}
```

Related parameters follow the names of `mod_auth_kerb` directives:

- `krb_method_negotiate`: Determines whether to use the Negotiate method. Default: 'on'.
- `krb_method_k5passwd`: Determines whether to use password-based authentication for Kerberos v5. Default: 'on'.
- `krb_authoritative`: If set to 'off', authentication controls can be passed on to another module. Default: 'on'.
- `krb_auth_realms`: Specifies an array of Kerberos realms to use for authentication. Default: '[]'.
- `krb_5keytab`: Specifies the Kerberos v5 keytab file's location. Default: `undef`.
- `krb_local_user_mapping`: Strips @REALM from usernames for further use. Default: `undef`.

Boolean. Default: `false`.

##### `krb_verify_kdc`

This option can be used to disable the verification tickets against local keytab to prevent KDC spoofing attacks.

Default: 'on'.

##### `krb_servicename`

Specifies the service name that will be used by Apache for authentication. Corresponding key of this name must be stored in the keytab.

Default: 'HTTP'.

##### `krb_save_credentials`

This option enables credential saving functionality.

Default is 'off'

##### `logroot`

Specifies the location of the virtual host's logfiles.

Default: '/var/log/<apache log location>/'.

##### `$logroot_ensure`

Determines whether or not to remove the logroot directory for a virtual host.

Values: 'directory', 'absent'.

Default: 'directory'.

##### `logroot_mode`

Overrides the mode the logroot directory is set to. Do *not* grant write access to the directory the logs are stored in without being aware of the consequences; for more information, see [Apache's log security documentation](https://httpd.apache.org/docs/2.4/logs.html#security).

Default: `undef`.

##### `logroot_owner`

Sets individual user access to the logroot directory.

Defaults to `undef`.

##### `logroot_group`

Sets group access to the [`logroot`][] directory.

Defaults to `undef`.

##### `log_level`

Specifies the verbosity of the error log.

Values: 'emerg', 'alert', 'crit', 'error', 'warn', 'notice', 'info' or 'debug'.

Default: 'warn' for the global server configuration. Can be overridden on a per-virtual host basis.

###### `modsec_body_limit`

Configures the maximum request body size (in bytes) ModSecurity accepts for buffering.

Values: An integer.

Default: `undef`.

###### `modsec_disable_vhost`

Disables [`mod_security`][] on a virtual host. Only valid if [`apache::mod::security`][] is included.

Boolean. Default: `undef`.

###### `modsec_disable_ids`

Removes `mod_security` IDs from the virtual host.

Values: An array of `mod_security` IDs to remove from the virtual host. Also takes a hash allowing removal of an ID from a specific location.

``` puppet
apache::vhost { 'sample.example.net':
  modsec_disable_ids => [ 90015, 90016 ],
}
```

``` puppet
apache::vhost { 'sample.example.net':
  modsec_disable_ids => { '/location1' => [ 90015, 90016 ] },
}
```

Default: `undef`.

###### `modsec_disable_ips`

Specifies an array of IP addresses to exclude from [`mod_security`][] rule matching.

Default: `undef`.

###### `modsec_disable_msgs`

Array of mod_security Msgs to remove from the virtual host. Also takes a hash allowing removal of an Msg from a specific location.

``` puppet
apache::vhost { 'sample.example.net':
  modsec_disable_msgs => [ 'Blind SQL Injection Attack', 'Session Fixation Attack' ],
}
```

``` puppet
apache::vhost { 'sample.example.net':
  modsec_disable_msgs => { '/location1' => [ 'Blind SQL Injection Attack', 'Session Fixation Attack' ] },
}
```

Default: `undef`.

###### `modsec_disable_tags`

Array of mod_security Tags to remove from the virtual host. Also takes a hash allowing removal of an Tag from a specific location.

``` puppet
apache::vhost { 'sample.example.net':
  modsec_disable_tags => [ 'WEB_ATTACK/SQL_INJECTION', 'WEB_ATTACK/XSS' ],
}
```

``` puppet
apache::vhost { 'sample.example.net':
  modsec_disable_tags => { '/location1' => [ 'WEB_ATTACK/SQL_INJECTION', 'WEB_ATTACK/XSS' ] },
}
```

Default: `undef`.

##### `modsec_audit*`

* `modsec_audit_log`
* `modsec_audit_log_file`
* `modsec_audit_log_pipe`

These three parameters together determine how to send `mod_security` audit log ([SecAuditLog](https://github.com/SpiderLabs/ModSecurity/wiki/Reference-Manual#SecAuditLog)).

* If `modsec_audit_log_file` is set, it is relative to [`logroot`][].

  Default: `undef`.

* If `modsec_audit_log_pipe` is set, it should start with a pipe. Example '|/path/to/mlogc /path/to/mlogc.conf'.

  Default: `undef`.

* If `modsec_audit_log` is `true`, given a virtual host---for instance, example.com---it defaults to 'example.com\_security\_ssl.log' for [SSL-encrypted][SSL encryption] virtual hosts and 'example.com\_security.log' for unencrypted virtual hosts.

  Default: `false`.

If none of those parameters are set, the global audit log is used (''/var/log/httpd/modsec\_audit.log''; Debian and derivatives: ''/var/log/apache2/modsec\_audit.log''; others: ).

##### `no_proxy_uris`

Specifies URLs you do not want to proxy. This parameter is meant to be used in combination with [`proxy_dest`](#proxy_dest).

Default: [].

##### `no_proxy_uris_match`

This directive is equivalent to [`no_proxy_uris`][], but takes regular expressions.

Default: [].

##### `proxy_preserve_host`

Sets the [ProxyPreserveHost Directive](https://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypreservehost). 

Setting this parameter to `true` enables the `Host:` line from an incoming request to be proxied to the host instead of hostname. Setting it to `false` sets this directive to 'Off'.

Boolean. Default: `false`.

##### `proxy_add_headers`

Sets the [ProxyAddHeaders Directive](https://httpd.apache.org/docs/current/mod/mod_proxy.html#proxyaddheaders). 

This parameter controlls whether proxy-related HTTP headers (X-Forwarded-For, X-Forwarded-Host and X-Forwarded-Server) get sent to the backend server.

Boolean. Default: `false`.

##### `proxy_error_override`

Sets the [ProxyErrorOverride Directive](https://httpd.apache.org/docs/current/mod/mod_proxy.html#proxyerroroverride). This directive controls whether Apache should override error pages for proxied content. 

Boolean. Default: `false`.

##### `options`

Sets the [`Options`][] for the specified virtual host. For example:

``` puppet
apache::vhost { 'site.name.fdqn':
  …
  options => ['Indexes','FollowSymLinks','MultiViews'],
}
```

> **Note**: If you use the [`directories`][] parameter of [`apache::vhost`][], 'Options', 'Override', and 'DirectoryIndex' are ignored because they are parameters within `directories`.

Default: ['Indexes','FollowSymLinks','MultiViews'],

##### `override`

Sets the overrides for the specified virtual host. Accepts an array of [AllowOverride](https://httpd.apache.org/docs/current/mod/core.html#allowoverride) arguments.

Default: '[none]'.

##### `passenger_app_root`

Sets [PassengerRoot](https://www.phusionpassenger.com/library/config/apache/reference/#passengerapproot), the location of the Passenger application root if different from the DocumentRoot.

Values: A string specifying a path.

Default: `undef`.

##### `passenger_app_env`

Sets [PassengerAppEnv](https://www.phusionpassenger.com/library/config/apache/reference/#passengerappenv), the environment for the Passenger application. If not specified, defaults to the global setting or 'production'.

Values: A string specifying the name of the environment.

Default: `undef`.

##### `passenger_log_file`

By default, Passenger log messages are written to the Apache global error log. With [PassengerLogFile](https://www.phusionpassenger.com/library/config/apache/reference/#passengerlogfile), you can configure those messages to be logged to a different file. This option is only available since Passenger 5.0.5.

Values: A string specifying a path.

Default: `undef`.

##### `passenger_log_level`

This option allows to specify how much information should be written to the log file. If not set, [PassengerLogLevel](https://www.phusionpassenger.com/library/config/apache/reference/#passengerloglevel) will not show up in the configuration file and the defaults are used. 

Default: Passenger versions less than 3.0.0: '0'; 5.0.0 and later: '3'.

##### `passenger_ruby`

Sets [PassengerRuby](https://www.phusionpassenger.com/library/config/apache/reference/#passengerruby), the Ruby interpreter to use for the application, on this virtual host.

Default: `undef`.

##### `passenger_min_instances`

Sets [PassengerMinInstances](https://www.phusionpassenger.com/library/config/apache/reference/#passengermininstances), the minimum number of application processes to run.

##### `passenger_max_requests`

Sets [PassengerMaxRequests](https://www.phusionpassenger.com/library/config/apache/reference/#pas
sengermaxrequests), the maximum number of requests an application process will process.

##### `passenger_max_instances_per_app`

Sets [PassengerMaxInstancesPerApp](https://www.phusionpassenger.com/library/config/apache/reference/#passengermaxinstancesperapp), the maximum number of application processes that may simultaneously exist for a single application.

Default: `undef`.

##### `passenger_start_timeout`

Sets [PassengerStartTimeout](https://www.phusionpassenger.com/library/config/apache/reference/#passengerstarttimeout), the timeout for the application startup.

##### `passenger_pre_start`

Sets [PassengerPreStart](https://www.phusionpassenger.com/library/config/apache/reference/#passengerprestart), the URL of the application if pre-starting is required.

##### `passenger_user`

Sets [PassengerUser](https://www.phusionpassenger.com/library/config/apache/reference/#passengeruser), the running user for sandboxing applications.

##### `passenger_high_performance`

Sets the [`PassengerHighPerformance`](https://www.phusionpassenger.com/library/config/apache/reference/#passengerhighperformance) parameter. Values: `true`, `false`. Default: `undef`.

##### `passenger_nodejs`

Sets the [`PassengerNodejs`](https://www.phusionpassenger.com/library/config/apache/reference/#passengernodejs), the NodeJS interpreter to use for the application, on this virtual host.

##### `passenger_sticky_sessions`

Sets the [`PassengerStickySessions`](https://www.phusionpassenger.com/library/config/apache/reference/#passengerstickysessions) parameter.

Boolean. Default: `undef`.

##### `passenger_startup_file`

Sets the [`PassengerStartupFile`](https://www.phusionpassenger.com/library/config/apache/reference/#passengerstartupfile) path. This path is relative to the application root.

##### `php_flags & values`

Allows per-virtual host setting [`php_value`s or `php_flag`s](http://php.net/manual/en/configuration.changes.php). These flags or values can be overwritten by a user or an application.

Default: '{}'.

##### `php_admin_flags & values`

Allows per-virtual host setting [`php_admin_value`s or `php_admin_flag`s](http://php.net/manual/en/configuration.changes.php). These flags or values cannot be overwritten by a user or an application.

Default: '{}'.

##### `port`

Sets the port the host is configured on. The module's defaults ensure the host listens on port 80 for non-SSL virtual hosts and port 443 for SSL virtual hosts. The host only listens on the port set in this parameter.

##### `priority`

Sets the relative load-order for Apache HTTPD VirtualHost configuration files.

If nothing matches the priority, the first name-based virtual host is used. Likewise, passing a higher priority causes the alphabetically first name-based virtual host to be used if no other names match.

> **Note:** You should not need to use this parameter. However, if you do use it, be aware that the `default_vhost` parameter for `apache::vhost` passes a priority of '15'.

To omit the priority prefix in file names, pass a priority of `false`.

Default: '25'.

##### `proxy_dest`

Specifies the destination address of a [ProxyPass](https://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypass) configuration.

Default: `undef`.

##### `proxy_pass`

Specifies an array of `path => URI` values for a [ProxyPass](https://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypass) configuration. Optionally, parameters can be added as an array.

Default: `undef`.

``` puppet
apache::vhost { 'site.name.fdqn':
  …
  proxy_pass => [
    { 'path' => '/a', 'url' => 'http://backend-a/' },
    { 'path' => '/b', 'url' => 'http://backend-b/' },
    { 'path' => '/c', 'url' => 'http://backend-a/c', 'params' => {'max'=>20, 'ttl'=>120, 'retry'=>300}},
    { 'path' => '/l', 'url' => 'http://backend-xy',
      'reverse_urls' => ['http://backend-x', 'http://backend-y'] },
    { 'path' => '/d', 'url' => 'http://backend-a/d',
      'params' => { 'retry' => '0', 'timeout' => '5' }, },
    { 'path' => '/e', 'url' => 'http://backend-a/e',
      'keywords' => ['nocanon', 'interpolate'] },
    { 'path' => '/f', 'url' => 'http://backend-f/',
      'setenv' => ['proxy-nokeepalive 1','force-proxy-request-1.0 1']},
    { 'path' => '/g', 'url' => 'http://backend-g/',
      'reverse_cookies' => [{'path' => '/g', 'url' => 'http://backend-g/',}, {'domain' => 'http://backend-g', 'url' => 'http:://backend-g',},], },
    { 'path' => '/h', 'url' => 'http://backend-h/h',
      'no_proxy_uris' => ['/h/admin', '/h/server-status'] },
  ],
}
```

* `reverse_urls`. *Optional.* This setting is useful when used with `mod_proxy_balancer`. Values: an array or string.
* `reverse_cookies`. *Optional.* Sets `ProxyPassReverseCookiePath` and `ProxyPassReverseCookieDomain`.
* `params`. *Optional.* Allows for ProxyPass key-value parameters, such as connection settings.
* `setenv`. *Optional.* Sets [environment variables](https://httpd.apache.org/docs/current/mod/mod_proxy.html#envsettings) for the proxy directive. Values: array.

##### `proxy_dest_match`

This directive is equivalent to [`proxy_dest`][], but takes regular expressions, see [ProxyPassMatch](https://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypassmatch) for details.

##### `proxy_dest_reverse_match`

Allows you to pass a ProxyPassReverse if [`proxy_dest_match`][] is specified. See [ProxyPassReverse](https://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypassreverse) for details.

##### `proxy_pass_match`

This directive is equivalent to [`proxy_pass`][], but takes regular expressions, see [ProxyPassMatch](https://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypassmatch) for details.

##### `rack_base_uris`

Specifies the resource identifiers for a rack configuration. The file paths specified are listed as rack application roots for [Phusion Passenger](http://www.modrails.com/documentation/Users%20guide%20Apache.html#_railsbaseuri_and_rackbaseuri) in the _rack.erb template.

Default: `undef`.

#####`passenger_base_uris`

Used to specify that the given URI is a Phusion Passenger-served application. The file paths specified are listed as passenger application roots for [Phusion Passenger](https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html#PassengerBaseURI) in the _passenger_base_uris.erb template.

Default: `undef`.

##### `redirect_dest`

Specifies the address to redirect to.

Default: `undef`.

##### `redirect_source`

Specifies the source URIs that redirect to the destination specified in `redirect_dest`. If more than one item for redirect is supplied, the source and destination must be the same length, and the items are order-dependent.

``` puppet
apache::vhost { 'site.name.fdqn':
  …
  redirect_source => ['/images','/downloads'],
  redirect_dest   => ['http://img.example.com/','http://downloads.example.com/'],
}
```

##### `redirect_status`

Specifies the status to append to the redirect.

Default: `undef`.

``` puppet
apache::vhost { 'site.name.fdqn':
  …
  redirect_status => ['temp','permanent'],
}
```

##### `redirectmatch_*`

* `redirectmatch_regexp`
* `redirectmatch_status`
* `redirectmatch_dest`

Determines which server status should be raised for a given regular expression and where to forward the user to. Entered as arrays.

Default: `undef`.

``` puppet
apache::vhost { 'site.name.fdqn':
  …
  redirectmatch_status => ['404','404'],
  redirectmatch_regexp => ['\.git(/.*|$)/','\.svn(/.*|$)'],
  redirectmatch_dest => ['http://www.example.com/1','http://www.example.com/2'],
}
```

##### `request_headers`

Modifies collected [request headers](https://httpd.apache.org/docs/current/mod/mod_headers.html#requestheader) in various ways, including adding additional request headers, removing request headers, and so on. 

Default: `undef`.

``` puppet
apache::vhost { 'site.name.fdqn':
  …
  request_headers => [
    'append MirrorID "mirror 12"',
    'unset MirrorID',
  ],
}
```

##### `rewrites`

Creates URL rewrite rules. Expects an array of hashes. 

Values: Hash keys that are any of 'comment', 'rewrite_base', 'rewrite_cond', 'rewrite_rule' or 'rewrite_map'.

Default: `undef`.

For example, you can specify that anyone trying to access index.html is served welcome.html

``` puppet
apache::vhost { 'site.name.fdqn':
  …
  rewrites => [ { rewrite_rule => ['^index\.html$ welcome.html'] } ]
}
```

The parameter allows rewrite conditions that, when `true`, execute the associated rule. For instance, if you wanted to rewrite URLs only if the visitor is using IE

``` puppet
apache::vhost { 'site.name.fdqn':
  …
  rewrites => [
    {
      comment      => 'redirect IE',
      rewrite_cond => ['%{HTTP_USER_AGENT} ^MSIE'],
      rewrite_rule => ['^index\.html$ welcome.html'],
    },
  ],
}
```

You can also apply multiple conditions. For instance, rewrite index.html to welcome.html only when the browser is Lynx or Mozilla (version 1 or 2)

``` puppet
apache::vhost { 'site.name.fdqn':
  …
  rewrites => [
    {
      comment      => 'Lynx or Mozilla v1/2',
      rewrite_cond => ['%{HTTP_USER_AGENT} ^Lynx/ [OR]', '%{HTTP_USER_AGENT} ^Mozilla/[12]'],
      rewrite_rule => ['^index\.html$ welcome.html'],
    },
  ],
}
```

Multiple rewrites and conditions are also possible

``` puppet
apache::vhost { 'site.name.fdqn':
  …
  rewrites => [
    {
      comment      => 'Lynx or Mozilla v1/2',
      rewrite_cond => ['%{HTTP_USER_AGENT} ^Lynx/ [OR]', '%{HTTP_USER_AGENT} ^Mozilla/[12]'],
      rewrite_rule => ['^index\.html$ welcome.html'],
    },
    {
      comment      => 'Internet Explorer',
      rewrite_cond => ['%{HTTP_USER_AGENT} ^MSIE'],
      rewrite_rule => ['^index\.html$ /index.IE.html [L]'],
    },
    {
      rewrite_base => /apps/,
      rewrite_rule => ['^index\.cgi$ index.php', '^index\.html$ index.php', '^index\.asp$ index.html'],
    },
    { comment      => 'Rewrite to lower case',
      rewrite_cond => ['%{REQUEST_URI} [A-Z]'],
      rewrite_map  => ['lc int:tolower'],
      rewrite_rule => ['(.*) ${lc:$1} [R=301,L]'],
    },
  ],
}
```

Refer to the [`mod_rewrite` documentation][`mod_rewrite`] for more details on what is possible with rewrite rules and conditions.

##### `rewrite_inherit`

Determines whether the virtual host inherits global rewrite rules.

Default: `false`.

Rewrite rules may be specified globally (in `$conf_file` or `$confd_dir`) or inside the virtual host `.conf` file. By default, virtual hosts do not inherit global settings. To activate inheritance, specify the `rewrites` parameter and set `rewrite_inherit` parameter to `true`:

``` puppet
apache::vhost { 'site.name.fdqn':
  …
  rewrites => [
    <rules>,
  ],
  rewrite_inherit => `true`,
}
```

> **Note**: The `rewrites` parameter is **required** for this to have effect

Apache activates global `Rewrite` rules inheritance if the virtual host files contains the following directives:

``` ApacheConf
RewriteEngine On
RewriteOptions Inherit
```

Refer to the [official `mod_rewrite` documentation](https://httpd.apache.org/docs/2.2/mod/mod_rewrite.html), section "Rewriting in Virtual Hosts".

##### `scriptalias`

Defines a directory of CGI scripts to be aliased to the path '/cgi-bin', such as '/usr/scripts'.

Default: `undef`.

##### `scriptaliases`

> **Note**: This parameter is deprecated in favor of the `aliases` parameter.

Passes an array of hashes to the virtual host to create either ScriptAlias or ScriptAliasMatch statements per the [`mod_alias` documentation][`mod_alias`].

``` puppet
scriptaliases => [
  {
    alias => '/myscript',
    path  => '/usr/share/myscript',
  },
  {
    aliasmatch => '^/foo(.*)',
    path       => '/usr/share/fooscripts$1',
  },
  {
    aliasmatch => '^/bar/(.*)',
    path       => '/usr/share/bar/wrapper.sh/$1',
  },
  {
    alias => '/neatscript',
    path  => '/usr/share/neatscript',
  },
]
```

The ScriptAlias and ScriptAliasMatch directives are created in the order specified. As with [Alias and AliasMatch](#aliases) directives, specify more specific aliases before more general ones to avoid shadowing.

##### `serveradmin`

Specifies the email address Apache displays when it renders one of its error pages. 

Default: `undef`.

##### `serveraliases`

Sets the [ServerAliases](https://httpd.apache.org/docs/current/mod/core.html#serveralias) of the site.

Default: '[]'.

##### `servername`

Sets the servername corresponding to the hostname you connect to the virtual host at. 

Default: the title of the resource.

##### `setenv`

Used by HTTPD to set environment variables for virtual hosts.

Default: '[]'.

Example:

``` puppet
apache::vhost { 'setenv.example.com':
  setenv => ['SPECIAL_PATH /foo/bin'],
}
```

##### `setenvif`

Used by HTTPD to conditionally set environment variables for virtual hosts.

Default: '[]'.

##### `setenvifnocase`

Used by HTTPD to conditionally set environment variables for virtual hosts (caseless matching).

Default: '[]'.

##### `suphp_*`

* `suphp_addhandler`
* `suphp_configpath`
* `suphp_engine`

Sets up a virtual host with [suPHP](http://suphp.org/DocumentationView.html?file=apache/CONFIG).

* `suphp_addhandler`. Default: 'php5-script' on RedHat and FreeBSD, and 'x-httpd-php' on Debian and Gentoo.
* `suphp_configpath`. Default: `undef` on RedHat and FreeBSD, and '/etc/php5/apache2' on Debian and Gentoo.
* `suphp_engine`. Values: 'on' or 'off'. Default: 'off'.

An example virtual host configuration with suPHP:

``` puppet
apache::vhost { 'suphp.example.com':
  port             => '80',
  docroot          => '/home/appuser/myphpapp',
  suphp_addhandler => 'x-httpd-php',
  suphp_engine     => 'on',
  suphp_configpath => '/etc/php5/apache2',
  directories      => { path => '/home/appuser/myphpapp',
    'suphp'        => { user => 'myappuser', group => 'myappgroup' },
  }
}
```

##### `vhost_name`

Enables name-based virtual hosting. If no IP is passed to the virtual host, but the virtual host is assigned a port, then the virtual host name is 'vhost_name:port'. If the virtual host has no assigned IP or port, the virtual host name is set to the title of the resource.

Default: '*'.

##### `virtual_docroot`

Sets up a virtual host with a wildcard alias subdomain mapped to a directory with the same name. For example, 'http://example.com' would map to '/var/www/example.com'.

Default: `false`.

``` puppet
apache::vhost { 'subdomain.loc':
  vhost_name      => '*',
  port            => '80',
  virtual_docroot => '/var/www/%-2+',
  docroot         => '/var/www',
  serveraliases   => ['*.loc',],
}
```

##### `wsgi*`

* `wsgi_daemon_process`
* `wsgi_daemon_process_options`
* `wsgi_process_group`
* `wsgi_script_aliases`
* `wsgi_pass_authorization`

Sets up a virtual host with [WSGI](https://github.com/GrahamDumpleton/mod_wsgi).

* `wsgi_daemon_process`: A hash that sets the name of the WSGI daemon, accepting [certain keys](http://modwsgi.readthedocs.org/en/latest/configuration-directives/WSGIDaemonProcess.html). Default: `undef`.
* `wsgi_daemon_process_options`. _Optional._ Default: `undef`.
* `wsgi_process_group`: Sets the group ID that the virtual host runs under. Default: `undef`.
* `wsgi_script_aliases`: Requires a hash of web paths to filesystem .wsgi paths. Default: `undef`.
* `wsgi_script_aliases_match`: Requires a hash of web path regexes to filesystem .wsgi paths. Default: `undef`
* `wsgi_pass_authorization`: Uses the WSGI application to handle authorization instead of Apache when set to 'On'. For more information, see [mod_wsgi's WSGIPassAuthorization documentation] (https://modwsgi.readthedocs.org/en/latest/configuration-directives/WSGIPassAuthorization.html). Default: `undef`, leading Apache to use its default value of 'Off'.
* `wsgi_chunked_request`: Enables support for chunked requests. Default: `undef`.

An example virtual host configuration with WSGI:

``` puppet
apache::vhost { 'wsgi.example.com':
  port                        => '80',
  docroot                     => '/var/www/pythonapp',
  wsgi_daemon_process         => 'wsgi',
  wsgi_daemon_process_options =>
    { processes    => '2',
      threads      => '15',
      display-name => '%{GROUP}',
     },
  wsgi_process_group          => 'wsgi',
  wsgi_script_aliases         => { '/' => '/var/www/demo.wsgi' },
  wsgi_chunked_request        => 'On',
}
```

#### Parameter `directories` for `apache::vhost`

The `directories` parameter within the `apache::vhost` class passes an array of hashes to the virtual host to create [Directory](https://httpd.apache.org/docs/current/mod/core.html#directory), [File](https://httpd.apache.org/docs/current/mod/core.html#files), and [Location](https://httpd.apache.org/docs/current/mod/core.html#location) directive blocks. These blocks take the form, '< Directory /path/to/directory>...< /Directory>'.

The `path` key sets the path for the directory, files, and location blocks. Its value must be a path for the 'directory', 'files', and 'location' providers, or a regex for the 'directorymatch', 'filesmatch', or 'locationmatch' providers. Each hash passed to `directories` **must** contain `path` as one of the keys.

The `provider` key is optional. If missing, this key defaults to 'directory'. Values: 'directory', 'files', 'proxy', 'location', 'directorymatch', 'filesmatch', 'proxymatch' or 'locationmatch'. If you set `provider` to 'directorymatch', it uses the keyword 'DirectoryMatch' in the Apache config file.

An example use of `directories`:

``` puppet
apache::vhost { 'files.example.net':
  docroot     => '/var/www/files',
  directories => [
    { 'path'     => '/var/www/files',
      'provider' => 'files',
      'deny'     => 'from all',
     },
  ],
}
```

> **Note:** At least one directory should match the `docroot` parameter. After you start declaring directories, `apache::vhost` assumes that all required Directory blocks will be declared. If not defined, a single default Directory block is created that matches the `docroot` parameter.

Available handlers, represented as keys, should be placed within the `directory`, `files`, or `location` hashes. This looks like

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [ { path => '/path/to/directory', handler => value } ],
}
```

Any handlers you do not set in these hashes are considered 'undefined' within Puppet and are not added to the virtual host, resulting in the module using their default values. Supported handlers are:

##### `addhandlers`

Sets [AddHandler](https://httpd.apache.org/docs/current/mod/mod_mime.html#addhandler) directives, which map filename extensions to the specified handler. Accepts a list of hashes, with `extensions` serving to list the extensions being managed by the handler, and takes the form: `{ handler => 'handler-name', extensions => ['extension'] }`.

An example:

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path        => '/path/to/directory',
      addhandlers => [{ handler => 'cgi-script', extensions => ['.cgi']}],
    },
  ],
}
```

##### `allow`

Sets an [Allow](https://httpd.apache.org/docs/2.2/mod/mod_authz_host.html#allow) directive, which groups authorizations based on hostnames or IPs. **Deprecated:** This parameter is being deprecated due to a change in Apache. It only works with Apache 2.2 and lower. You can use it as a single string for one rule or as an array for more than one.

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path  => '/path/to/directory',
      allow => 'from example.org',
    },
  ],
}
```

##### `allow_override`

Sets the types of directives allowed in [.htaccess](https://httpd.apache.org/docs/current/mod/core.html#allowoverride) files. Accepts an array.

``` puppet
apache::vhost { 'sample.example.net':
  docroot      => '/path/to/directory',
  directories  => [
    { path           => '/path/to/directory',
      allow_override => ['AuthConfig', 'Indexes'],
    },
  ],
}
```

##### `auth_basic_authoritative`

Sets the value for [AuthBasicAuthoritative](https://httpd.apache.org/docs/current/mod/mod_auth_basic.html#authbasicauthoritative), which determines whether authorization and authentication are passed to lower level Apache modules.

##### `auth_basic_fake`

Sets the value for [AuthBasicFake](https://httpd.apache.org/docs/current/mod/mod_auth_basic.html#authbasicfake), which statically configures authorization credentials for a given directive block.

##### `auth_basic_provider`

Sets the value for [AuthBasicProvider](https://httpd.apache.org/docs/current/mod/mod_auth_basic.html#authbasicprovider), which sets the authentication provider for a given location.

##### `auth_digest_algorithm`

Sets the value for [AuthDigestAlgorithm](https://httpd.apache.org/docs/current/mod/mod_auth_digest.html#authdigestalgorithm), which selects the algorithm used to calculate the challenge and response hashes.

###### `auth_digest_domain`

Sets the value for [AuthDigestDomain](https://httpd.apache.org/docs/current/mod/mod_auth_digest.html#authdigestdomain), which allows you to specify one or more URIs in the same protection space for digest authentication.

##### `auth_digest_nonce_lifetime`

Sets the value for [AuthDigestNonceLifetime](https://httpd.apache.org/docs/current/mod/mod_auth_digest.html#authdigestnoncelifetime), which controls how long the server nonce is valid.

##### `auth_digest_provider`

Sets the value for [AuthDigestProvider](https://httpd.apache.org/docs/current/mod/mod_auth_digest.html#authdigestprovider), which sets the authentication provider for a given location.

##### `auth_digest_qop`

Sets the value for [AuthDigestQop](https://httpd.apache.org/docs/current/mod/mod_auth_digest.html#authdigestqop), which determines the quality-of-protection to use in digest authentication.

##### `auth_digest_shmem_size`

Sets the value for [AuthAuthDigestShmemSize](https://httpd.apache.org/docs/current/mod/mod_auth_digest.html#authdigestshmemsize), which defines the amount of shared memory allocated to the server for keeping track of clients.

##### `auth_group_file`

Sets the value for [AuthGroupFile](https://httpd.apache.org/docs/current/mod/mod_authz_groupfile.html#authgroupfile), which sets the name of the text file containing the list of user groups for authorization.

##### `auth_name`

Sets the value for [AuthName](https://httpd.apache.org/docs/current/mod/mod_authn_core.html#authname), which sets the name of the authorization realm.

##### `auth_require`

Sets the entity name you're requiring to allow access. Read more about [Require](https://httpd.apache.org/docs/current/mod/mod_authz_host.html#requiredirectives).

##### `auth_type`

Sets the value for [AuthType](https://httpd.apache.org/docs/current/mod/mod_authn_core.html#authtype), which guides the type of user authentication.

##### `auth_user_file`

Sets the value for [AuthUserFile](https://httpd.apache.org/docs/current/mod/mod_authn_file.html#authuserfile), which sets the name of the text file containing the users/passwords for authentication.

##### `auth_merging`

Sets the value for [AuthMerging](https://httpd.apache.org/docs/current/mod/mod_authz_core.html#authmerging), which determines if authorization logic should be combined

##### `auth_ldap_url`

Sets the value for [AuthLDAPURL](https://httpd.apache.org/docs/current/mod/mod_authnz_ldap.html#authldapurl), which determines URL of LDAP-server(s) if AuthBasicProvider 'ldap' is used

##### `auth_ldap_bind_dn`

Sets the value for [AuthLDAPBindDN](https://httpd.apache.org/docs/current/mod/mod_authnz_ldap.html#authldapbinddn), which allows use of an optional DN used to bind to the LDAP-server when searching for entries if AuthBasicProvider 'ldap' is used.

##### `auth_ldap_bind_password`

Sets the value for [AuthLDAPBindPassword](https://httpd.apache.org/docs/current/mod/mod_authnz_ldap.html#authldapbindpassword), which allows use of an optional bind password to use in conjunction with the bind DN if AuthBasicProvider 'ldap' is used.

##### `auth_ldap_group_attribute`

Array of values for [AuthLDAPGroupAttribute](https://httpd.apache.org/docs/current/mod/mod_authnz_ldap.html#authldapgroupattribute), specifies which LDAP attributes are used to check for user members within ldap-groups. Defaults are: "member" and "uniquemember".

##### `auth_ldap_group_attribute_is_dn`

Sets value for [AuthLDAPGroupAttributeIsDN](https://httpd.apache.org/docs/current/mod/mod_authnz_ldap.html#authldapgroupattributeisdn), specifies if member of a ldapgroup is a dn or simple username. When set on, this directive says to use the distinguished name of the client username when checking for group membership. Otherwise, the username will be used. valid values are: "on" or "off"

##### `custom_fragment`

Pass a string of custom configuration directives to be placed at the end of the directory configuration.

``` puppet
apache::vhost { 'monitor':
  …
  directories => [
    {
      path => '/path/to/directory',
      custom_fragment => '
<Location /balancer-manager>
  SetHandler balancer-manager
  Order allow,deny
  Allow from all
</Location>
<Location /server-status>
  SetHandler server-status
  Order allow,deny
  Allow from all
</Location>
ProxyStatus On',
    },
  ]
}
```

##### `dav`

Sets the value for [Dav](http://httpd.apache.org/docs/current/mod/mod_dav.html#dav), which determines if the WebDAV HTTP methods should be enabled. The value can be either 'On', 'Off' or the name of the provider. A value of 'On' enables the default filesystem provider implemented by the `mod_dav_fs` module.

##### `dav_depth_infinity`

Sets the value for [DavDepthInfinity](http://httpd.apache.org/docs/current/mod/mod_dav.html#davdepthinfinity), which is used to enable the processing of `PROPFIND` requests having a `Depth: Infinity` header.

##### `dav_min_timeout`

Sets the value for [DavMinTimeout](http://httpd.apache.org/docs/current/mod/mod_dav.html#davmintimeout), which sets the time the server holds a lock on a DAV resource. The value should be the number of seconds to set.

##### `deny`

Sets a [Deny](https://httpd.apache.org/docs/2.2/mod/mod_authz_host.html#deny) directive, specifying which hosts are denied access to the server. **Deprecated:** This parameter is being deprecated due to a change in Apache. It only works with Apache 2.2 and lower. You can use it as a single string for one rule or as an array for more than one.

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path => '/path/to/directory',
      deny => 'from example.org',
    },
  ],
}
```

##### `error_documents`

An array of hashes used to override the [ErrorDocument](https://httpd.apache.org/docs/current/mod/core.html#errordocument) settings for the directory.

``` puppet
apache::vhost { 'sample.example.net':
  directories => [
    { path            => '/srv/www',
      error_documents => [
        { 'error_code' => '503',
          'document'   => '/service-unavail',
        },
      ],
    },
  ],
}
```

##### `ext_filter_options`

Sets the [ExtFilterOptions](https://httpd.apache.org/docs/current/mod/mod_ext_filter.html) directive.
Note that you must declare `class { 'apache::mod::ext_filter': }` before using this directive.

``` puppet
apache::vhost { 'filter.example.org':
  docroot     => '/var/www/filter',
  directories => [
    { path               => '/var/www/filter',
      ext_filter_options => 'LogStderr Onfail=abort',
    },
  ],
}
```

##### `geoip_enable`

Sets the [GeoIPEnable](http://dev.maxmind.com/geoip/legacy/mod_geoip2/#Configuration) directive.
Note that you must declare `class {'apache::mod::geoip': }` before using this directive.

``` puppet
apache::vhost { 'first.example.com':
  docroot     => '/var/www/first',
  directories => [
    { path         => '/var/www/first',
      geoip_enable => `true`,
    },
  ],
}
```

##### `headers`

Adds lines for [Header](https://httpd.apache.org/docs/current/mod/mod_headers.html#header) directives.

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => {
    path    => '/path/to/directory',
    headers => 'Set X-Robots-Tag "noindex, noarchive, nosnippet"',
  },
}
```

##### `index_options`

Allows configuration settings for [directory indexing](https://httpd.apache.org/docs/current/mod/mod_autoindex.html#indexoptions).

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path           => '/path/to/directory',
      directoryindex => 'disabled', # this is needed on Apache 2.4 or mod_autoindex doesn't work
      options        => ['Indexes','FollowSymLinks','MultiViews'],
      index_options  => ['IgnoreCase', 'FancyIndexing', 'FoldersFirst', 'NameWidth=*', 'DescriptionWidth=*', 'SuppressHTMLPreamble'],
    },
  ],
}
```

##### `index_order_default`

Sets the [default ordering](https://httpd.apache.org/docs/current/mod/mod_autoindex.html#indexorderdefault) of the directory index.

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path                => '/path/to/directory',
      order               => 'Allow,Deny',
      index_order_default => ['Descending', 'Date'],
    },
  ],
}
```

###### `index_style_sheet`

Sets the [IndexStyleSheet](https://httpd.apache.org/docs/current/mod/mod_autoindex.html#indexstylesheet), which adds a CSS stylesheet to the directory index.

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path              => '/path/to/directory',
      options           => ['Indexes','FollowSymLinks','MultiViews'],
      index_options     => ['FancyIndexing'],
      index_style_sheet => '/styles/style.css',
    },
  ],
}
```

##### `limit`

Creates a [Limit](https://httpd.apache.org/docs/current/mod/core.html#limit) block inside the Directory block, which can also contain `require` directives.

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/docroot',
  directories => [
    { path     => '/',
      provider => 'location',
      limit    => [
        { methods => 'GET HEAD',
          require => ['valid-user']
        },
      ],
    },
  ],
}
```

##### `limit_except`

Creates a [LimitExcept](https://httpd.apache.org/docs/current/mod/core.html#limitexcept) block inside the Directory block, which can also contain `require` directives.

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/docroot',
  directories => [
    { path         => '/',
      provider     => 'location',
      limit_except => [
        { methods => 'GET HEAD',
          require => ['valid-user']
        },
      ],
    },
  ],
}
```

##### `mellon_enable`

Sets the [MellonEnable][`mod_auth_mellon`] directory to enable [`mod_auth_mellon`][]. You can use [`apache::mod::auth_mellon`][] to install `mod_auth_mellon`.

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path                       => '/',
      provider                   => 'directory',
      mellon_enable              => 'info',
      mellon_sp_private_key_file => '/etc/certs/${::fqdn}.key',
      mellon_endpoint_path       => '/mellon',
      mellon_set_env_no_prefix   => { 'ADFS_GROUP' => 'http://schemas.xmlsoap.org/claims/Group',
                                      'ADFS_EMAIL' => 'http://schemas.xmlsoap.org/claims/EmailAddress', },
      mellon_user => 'ADFS_LOGIN',
    },
    { path          => '/protected',
      provider      => 'location',
      mellon_enable => 'auth',
      auth_type     => 'Mellon',
      auth_require  => 'valid-user',
      mellon_cond   => ['ADFS_LOGIN userA [MAP]','ADFS_LOGIN userB [MAP]'],
    },
  ]
}
```

Related parameters follow the names of `mod_auth_mellon` directives:

- `mellon_cond`: Takes an array of mellon conditions that must be met to grant access, and creates a [MellonCond][`mod_auth_mellon`] directive for each item in the array.
- `mellon_endpoint_path`: Sets the [MellonEndpointPath][`mod_auth_mellon`] to set the mellon endpoint path.
- `mellon_sp_metadata_file`: Sets the [MellonSPMetadataFile][`mod_auth_mellon`] location of the SP metadata file.
- `mellon_idp_metadata_file`: Sets the [MellonIDPMetadataFile][`mod_auth_mellon`] location of the IDP metadata file.
- `mellon_saml_rsponse_dump`: Sets the [MellonSamlResponseDump][`mod_auth_mellon`] directive to enable debug of SAML.
- `mellon_set_env_no_prefix`: Sets the [MellonSetEnvNoPrefix][`mod_auth_mellon`] directive to a hash of attribute names to map
to environment variables.
- `mellon_sp_private_key_file`: Sets the [MellonSPPrivateKeyFile][`mod_auth_mellon`] directive for the private key location of the service provider.
- `mellon_sp_cert_file`: Sets the [MellonSPCertFile][`mod_auth_mellon`] directive for the public key location of the service provider.
- `mellon_user`: Sets the [MellonUser][`mod_auth_mellon`] attribute to use for the username.

##### `options`

Lists the [Options](https://httpd.apache.org/docs/current/mod/core.html#options) for the given Directory block.

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path    => '/path/to/directory',
      options => ['Indexes','FollowSymLinks','MultiViews'],
    },
  ],
}
```

##### `order`

Sets the order of processing Allow and Deny statements as per [Apache core documentation](https://httpd.apache.org/docs/2.2/mod/mod_authz_host.html#order). **Deprecated:** This parameter is being deprecated due to a change in Apache. It only works with Apache 2.2 and lower.

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path  => '/path/to/directory',
      order => 'Allow,Deny',
    },
  ],
}
```

##### `passenger_enabled`

Sets the value for the [PassengerEnabled](http://www.modrails.com/documentation/Users%20guide%20Apache.html#PassengerEnabled) directive to 'on' or 'off'. Requires `apache::mod::passenger` to be included.

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path              => '/path/to/directory',
      passenger_enabled => 'on',
    },
  ],
}
```

> **Note:** There is an [issue](http://www.conandalton.net/2010/06/passengerenabled-off-not-working.html) using the PassengerEnabled directive with the PassengerHighPerformance directive.

##### `php_value` and `php_flag`

`php_value` sets the value of the directory, and `php_flag` uses a boolean to configure the directory. Further information can be found [here](http://php.net/manual/en/configuration.changes.php).

##### `php_admin_value` and `php_admin_flag`

`php_admin_value` sets the value of the directory, and `php_admin_flag` uses a boolean to configure the directory. Further information can be found [here](http://php.net/manual/en/configuration.changes.php).


##### `require`


Sets a `Require` directive as per the [Apache Authz documentation](https://httpd.apache.org/docs/current/mod/mod_authz_core.html#require). If no `require` is set, it will default to `Require all granted`.

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path    => '/path/to/directory',
      require => 'ip 10.17.42.23',
    }
  ],
}
```

When more complex sets of requirement are needed, apache >= 2.4 provides the use of [RequireAll](https://httpd.apache.org/docs/2.4/mod/mod_authz_core.html#requireall), [RequireNone](https://httpd.apache.org/docs/2.4/mod/mod_authz_core.html#requirenone) or [RequireAny](https://httpd.apache.org/docs/2.4/mod/mod_authz_core.html#requireany) directives.
Using the 'enforce' key, which only supports 'any','none','all' (other values are silently ignored), this could be established like:

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path    => '/path/to/directory',
      require => {
        enforce  => 'any',
        requires => [
          'ip 1.2.3.4',
          'not host host.example.com',
          'user xyz',
        ],
      },
    },
  ],
}
```

If `require` is set to `unmanaged` it will not be set at all. This is useful for complex authentication/authorization requirements which are handled in a custom fragment.

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path    => '/path/to/directory',
      require => 'unmanaged',
    }
  ],
}
```



##### `satisfy`

Sets a `Satisfy` directive per the [Apache Core documentation](https://httpd.apache.org/docs/2.2/mod/core.html#satisfy). **Deprecated:** This parameter is deprecated due to a change in Apache and only works with Apache 2.2 and lower.

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path    => '/path/to/directory',
      satisfy => 'Any',
    }
  ],
}
```

##### `sethandler`

Sets a `SetHandler` directive per the [Apache Core documentation](https://httpd.apache.org/docs/2.2/mod/core.html#sethandler).

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path       => '/path/to/directory',
      sethandler => 'None',
    }
  ],
}
```

##### `set_output_filter`

Sets a `SetOutputFilter` directive per the [Apache Core documentation](https://httpd.apache.org/docs/current/mod/core.html#setoutputfilter).

``` puppet
apache::vhost{ 'filter.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path              => '/path/to/directory',
      set_output_filter => puppetdb-strip-resource-params,
    },
  ],
}
```

##### `rewrites`

Creates URL [`rewrites`](#rewrites) rules in virtual host directories. Expects an array of hashes, and the hash keys can be any of 'comment', 'rewrite_base', 'rewrite_cond', or 'rewrite_rule'.

``` puppet
apache::vhost { 'secure.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path        => '/path/to/directory',
      rewrites => [ { comment      => 'Permalink Rewrites',
                      rewrite_base => '/'
                    },
                    { rewrite_rule => [ '^index\.php$ - [L]' ]
                    },
                    { rewrite_cond => [ '%{REQUEST_FILENAME} !-f',
                                        '%{REQUEST_FILENAME} !-d',
                                      ],
                      rewrite_rule => [ '. /index.php [L]' ],
                    }
                  ],
    },
  ],
}
```

> **Note**: If you include rewrites in your directories, also include `apache::mod::rewrite` and consider setting the rewrites using the `rewrites` parameter in `apache::vhost` rather than setting the rewrites in the virtual host's directories.

##### `shib_request_settings`

Allows a valid content setting to be set or altered for the application request. This command takes two parameters: the name of the content setting, and the value to set it to. Check the Shibboleth [content setting documentation](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPContentSettings) for valid settings. This key is disabled if `apache::mod::shib` is not defined. Check the [`mod_shib` documentation](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPApacheConfig#NativeSPApacheConfig-Server/VirtualHostOptions) for more details.

``` puppet
apache::vhost { 'secure.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path                  => '/path/to/directory',
      shib_request_settings => { 'requiresession' => 'On' },
      shib_use_headers      => 'On',
    },
  ],
}
```

##### `shib_use_headers`

When set to 'On', this turns on the use of request headers to publish attributes to applications. Values for this key is 'On' or 'Off', and the default value is 'Off'. This key is disabled if `apache::mod::shib` is not defined. Check the [`mod_shib` documentation](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPApacheConfig#NativeSPApacheConfig-Server/VirtualHostOptions) for more details.

##### `ssl_options`

String or list of [SSLOptions](https://httpd.apache.org/docs/current/mod/mod_ssl.html#ssloptions), which configure SSL engine run-time options. This handler takes precedence over SSLOptions set in the parent block of the virtual host.

``` puppet
apache::vhost { 'secure.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path        => '/path/to/directory',
      ssl_options => '+ExportCertData',
    },
    { path        => '/path/to/different/dir',
      ssl_options => [ '-StdEnvVars', '+ExportCertData'],
    },
  ],
}
```

##### `suphp`

A hash containing the 'user' and 'group' keys for the [suPHP_UserGroup](http://www.suphp.org/DocumentationView.html?file=apache/CONFIG) setting. It must be used with `suphp_engine => on` in the virtual host declaration, and can only be passed within `directories`.

``` puppet
apache::vhost { 'secure.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path  => '/path/to/directory',
      suphp => {
        user  => 'myappuser',
        group => 'myappgroup',
      },
    },
  ],
}
```
##### `additional_includes`

Specifies paths to additional static, specific Apache configuration files in virtual host directories. Values: a array of string path.

``` puppet
apache::vhost { 'sample.example.net':
  docroot     => '/path/to/directory',
  directories => [
    { path  => '/path/to/different/dir',
      additional_includes => [ '/custom/path/includes', '/custom/path/another_includes', ],
    },
  ],
}
```

#### SSL parameters for `apache::vhost`

All of the SSL parameters for `::vhost` default to whatever is set in the base `apache` class. Use the below parameters to tweak individual SSL settings for specific virtual hosts.

##### `ssl`

Enables SSL for the virtual host. SSL virtual hosts only respond to HTTPS queries. Values: Boolean.

Default: `false`.

##### `ssl_ca`

Specifies the SSL certificate authority.

Default: `undef`.

##### `ssl_cert`

Specifies the SSL certification. Defaults are based on your OS.

* RedHat: '/etc/pki/tls/certs/localhost.crt'
* Debian: '/etc/ssl/certs/ssl-cert-snakeoil.pem'
* FreeBSD: '/usr/local/etc/apache22/server.crt'
* Gentoo: '/etc/ssl/apache2/server.crt'

##### `ssl_protocol`

Specifies [SSLProtocol](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslprotocol). Expects an array or space separated string of accepted protocols.

Defaults: 'all', '-SSLv2', '-SSLv3'.

##### `ssl_cipher`

Specifies [SSLCipherSuite](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslciphersuite). 

Default: 'HIGH:MEDIUM:!aNULL:!MD5'.

##### `ssl_honorcipherorder`

Sets [SSLHonorCipherOrder](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslhonorcipherorder), to cause Apache to use the server's preferred order of ciphers rather than the client's preferred order. Values:

Values: Boolean, 'on', 'off'.

Default: `true`.

##### `ssl_certs_dir`

Specifies the location of the SSL certification directory. Default: Depends on operating system.

- Debian: '/etc/ssl/certs'
- Red Hat: '/etc/pki/tls/certs'
- FreeBSD: `undef`
- Gentoo: '/etc/ssl/apache2'

##### `ssl_chain`

Specifies the SSL chain. This default works out of the box, but it must be updated in the base `apache` class with your specific certificate information before being used in production.

Default: `undef`. 

##### `ssl_crl`

Specifies the certificate revocation list to use. (This default works out of the box but must be updated in the base `apache` class with your specific certificate information before being used in production.)

Default: `undef`.

##### `ssl_crl_path`

Specifies the location of the certificate revocation list. (This default works out of the box but must be updated in the base `apache` class with your specific certificate information before being used in production.)

Default: `undef`. 

##### `ssl_crl_check`

Sets the certificate revocation check level via the [SSLCARevocationCheck directive](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslcarevocationcheck). The default works out of the box but must be specified when using CRLs in production. Only applicable to Apache 2.4 or higher; the value is ignored on older versions.

Default: `undef`.

##### `ssl_key`

Specifies the SSL key. Defaults are based on your operating system. Default work out of the box but must be updated in the base `apache` class with your specific certificate information before being used in production.

* RedHat: '/etc/pki/tls/private/localhost.key'
* Debian: '/etc/ssl/private/ssl-cert-snakeoil.key'
* FreeBSD: '/usr/local/etc/apache22/server.key'
* Gentoo: '/etc/ssl/apache2/server.key'

##### `ssl_verify_client`

Sets the [SSLVerifyClient](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslverifyclient) directive, which sets the certificate verification level for client authentication.

``` puppet
apache::vhost { 'sample.example.net':
  …
  ssl_verify_client => 'optional',
}
```

Values: 'none', 'optional', 'require', and 'optional_no_ca'.

Default: `undef`.


##### `ssl_verify_depth`

Sets the [SSLVerifyDepth](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslverifydepth) directive, which specifies the maximum depth of CA certificates in client certificate verification.

``` puppet
apache::vhost { 'sample.example.net':
  …
  ssl_verify_depth => 1,
}
```

Default: `undef`.

##### `ssl_proxy_protocol`

Sets the [SSLProxyProtocol](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslproxyprotocol) directive, which controls which SSL protocol flavors `mod_ssl` should use when establishing its server environment for proxy. It connects to servers using only one of the provided protocols.

Default: `undef`.

##### `ssl_proxy_verify`

Sets the [SSLProxyVerify](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslproxyverify) directive, which configures certificate verification of the remote server when a proxy is configured to forward requests to a remote SSL server.

Default: `undef`.

##### `ssl_proxy_verify_depth`

Sets the [SSLProxyVerifyDepth](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslproxyverifydepth) directive, which configures how deeply mod_ssl should verify before deciding that the remote server does not have a valid certificate.

A depth of 0 means that only self-signed remote server certificates are accepted, the default depth of 1 means the remote server certificate can be self-signed or signed by a CA that is directly known to the server.

Default: `undef`

##### `ssl_proxy_ca_cert`

Sets the [SSLProxyCACertificateFile](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslproxycacertificatefile) directive, which specifies an all-in-one file where you can assemble the Certificates of Certification Authorities (CA) whose remote servers you deal with. These are used for Remote Server Authentication. This file should be a concatenation of the PEM-encoded certificate files in order of preference.

Default: `undef`

##### `ssl_proxy_machine_cert`

Sets the [SSLProxyMachineCertificateFile](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslproxymachinecertificatefile) directive, which specifies an all-in-one file where you keep the certs and keys used for this server to authenticate itself to remote servers. This file should be a concatenation of the PEM-encoded certificate files in order of preference.

``` puppet
apache::vhost { 'sample.example.net':
  …
  ssl_proxy_machine_cert => '/etc/httpd/ssl/client_certificate.pem',
}
```

Default: `undef`

##### `ssl_proxy_check_peer_cn`

Sets the [SSLProxyCheckPeerCN](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslproxycheckpeercn) directive, which specifies whether the remote server certificate's CN field is compared against the hostname of the request URL.

Values: 'on', 'off'.

Default: `undef`

##### `ssl_proxy_check_peer_name`

Sets the [SSLProxyCheckPeerName](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslproxycheckpeername) directive, which specifies whether the remote server certificate's CN field is compared against the hostname of the request URL.

Values: 'on', 'off'.

Default: `undef`

##### `ssl_proxy_check_peer_expire`

Sets the [SSLProxyCheckPeerExpire](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslproxycheckpeerexpire) directive, which specifies whether the remote server certificate is checked for expiration or not.

Values: 'on', 'off'.

Default: `undef`

##### `ssl_options`

Sets the [SSLOptions](https://httpd.apache.org/docs/current/mod/mod_ssl.html#ssloptions) directive, which configures various SSL engine run-time options. This is the global setting for the given virtual host and can be a string or an array.

A string:

``` puppet
apache::vhost { 'sample.example.net':
  …
  ssl_options => '+ExportCertData',
}
```

An array:

``` puppet
apache::vhost { 'sample.example.net':
  …
  ssl_options => [ '+StrictRequire', '+ExportCertData' ],
}
```

Default: `undef`.

##### `ssl_openssl_conf_cmd`

Sets the [SSLOpenSSLConfCmd](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslopensslconfcmd) directive, which provides direct configuration of OpenSSL parameters. 

Default: `undef`

##### `ssl_proxyengine`

Specifies whether or not to use [SSLProxyEngine](https://httpd.apache.org/docs/current/mod/mod_ssl.html#sslproxyengine). 

Boolean.

Default: `true`.

##### `ssl_stapling`

Specifies whether or not to use [SSLUseStapling](http://httpd.apache.org/docs/current/mod/mod_ssl.html#sslusestapling). By default, uses what is set globally.

This parameter only applies to Apache 2.4 or higher and is ignored on older versions.

Boolean or `undef`.

Default: `undef`

##### `ssl_stapling_timeout`

Can be used to set the [SSLStaplingResponderTimeout](http://httpd.apache.org/docs/current/mod/mod_ssl.html#sslstaplingrespondertimeout) directive.

This parameter only applies to Apache 2.4 or higher and is ignored on older versions.

Default: none.

##### `ssl_stapling_return_errors`

Can be used to set the [SSLStaplingReturnResponderErrors](http://httpd.apache.org/docs/current/mod/mod_ssl.html#sslstaplingreturnrespondererrors) directive.

This parameter only applies to Apache 2.4 or higher and is ignored on older versions.

Default: none.

#### Defined type: FastCGI Server

This type is intended for use with mod\_fastcgi. It allows you to define one or more external FastCGI servers to handle specific file types.

** Note ** If using Ubuntu 10.04+, you'll need to manually enable the multiverse repository.

Ex:

``` puppet
apache::fastcgi::server { 'php':
  host        => '127.0.0.1:9000',
  timeout     => 15,
  flush       => `false`,
  faux_path   => '/var/www/php.fcgi',
  fcgi_alias  => '/php.fcgi',
  file_type   => 'application/x-httpd-php',
  pass_header => ''
}
```

Within your virtual host, you can then configure the specified file type to be handled by the fastcgi server specified above.

``` puppet
apache::vhost { 'www':
  ...
  custom_fragment => 'AddType application/x-httpd-php .php'
  ...
}
```

##### `host`

The hostname or IP address and TCP port number (1-65535) of the FastCGI server.

It is also possible to pass a unix socket:

``` puppet
apache::fastcgi::server { 'php':
  host        => '/var/run/fcgi.sock',
}
```

##### `timeout`

The number of seconds of FastCGI application inactivity allowed before the request is aborted and the event is logged (at the error LogLevel). The inactivity timer applies only as long as a connection is pending with the FastCGI application. If a request is queued to an application, but the application doesn't respond (by writing and flushing) within this period, the request is aborted. If communication is complete with the application but incomplete with the client (the response is buffered), the timeout does not apply.

##### `flush`

Force a write to the client as data is received from the application. By default, `mod_fastcgi` buffers data in order to free the application as quickly as possible.

##### `faux_path`

Does not have to exist in the local filesystem. URIs that Apache resolves to this filename are handled by this external FastCGI application.

##### `alias`

A unique alias. This is used internally to link the action with the FastCGI server.

##### `file_type`

The MIME-type of the file to be processed by the FastCGI server.

##### `pass_header`

The name of an HTTP Request Header to be passed in the request environment. This option makes available the contents of headers which are normally not available (e.g. Authorization) to a CGI environment.

#### Defined type: `apache::vhost::custom`

The `apache::vhost::custom` defined type is a thin wrapper around the `apache::custom_config` defined type, and simply overrides some of its default settings specific to the virtual host directory in Apache.

**Parameters within `apache::vhost::custom`**:

##### `content`

Sets the configuration file's content.

##### `ensure`

Specifies if the virtual host file is present or absent.

Values: 'absent', 'present'.

Default: 'present'.

##### `priority`

Sets the relative load order for Apache HTTPD VirtualHost configuration files.

Default: '25'.

##### `verify_config`

Specifies whether to validate the configuration file before notifying the Apache service. 

Boolean.

Default: `true`.

### Private defined types

#### Defined type: `apache::peruser::multiplexer`

This defined type checks if an Apache module has a class. If it does, it includes that class. If it does not, it passes the module name to the [`apache::mod`][] defined type.

#### Defined type: `apache::peruser::multiplexer`

Enables the [`Peruser`][] module for FreeBSD only.

#### Defined type: `apache::peruser::processor`

Enables the [`Peruser`][] module for FreeBSD only.

#### Defined type: `apache::security::file_link`

Links the `activated_rules` from [`apache::mod::security`][] to the respective CRS rules on disk.

### Templates

The Apache module relies heavily on templates to enable the [`apache::vhost`][] and [`apache::mod`][] defined types. These templates are built based on [Facter][] facts specific to your operating system. Unless explicitly called out, most templates are not meant for configuration.

## Limitations

### General

This module is CI tested against both [open source Puppet][] and [Puppet Enterprise][] on:

- CentOS 5 and 6
- Ubuntu 12.04 and 14.04
- Debian 7
- RHEL 5, 6, and 7

This module also provides functions for other distributions and operating systems, such as FreeBSD, Gentoo, and Amazon Linux, but is not formally tested on them and are subject to regressions.

### FreeBSD

In order to use this module on FreeBSD, you _must_ use apache24-2.4.12 (www/apache24) or newer.

### Gentoo

On Gentoo, this module depends on the [`gentoo/puppet-portage`][] Puppet module. Although several options apply or enable certain features and settings for Gentoo, it is not a [supported operating system][] for this module.

### RHEL/CentOS
The [`apache::mod::auth_cas`][], [`apache::mod::passenger`][], [`apache::mod::proxy_html`][] and [`apache::mod::shib`][] classes are not functional on RH/CentOS without providing dependency packages from extra repositories.

See their respective documentation below for related repositories and packages.

#### RHEL/CentOS 5

The [`apache::mod::passenger`][] and [`apache::mod::proxy_html`][] classes are untested because repositories are missing compatible packages.

#### RHEL/CentOS 6

The [`apache::mod::passenger`][] class is not installing, because the the EL6 repository is missing compatible packages.

#### RHEL/CentOS 7

The [`apache::mod::passenger`][] and [`apache::mod::proxy_html`][] classes are untested because the EL7 repository is missing compatible packages, which also blocks us from testing the [`apache::vhost`][] defined type's [`rack_base_uris`][] parameter.

### SELinux and custom paths

If [SELinux][] is in [enforcing mode][] and you want to use custom paths for `logroot`, `mod_dir`, `vhost_dir`, and `docroot`, you need to manage the files' context yourself.

You can do this with Puppet:

``` puppet
exec { 'set_apache_defaults':
  command => 'semanage fcontext -a -t httpd_sys_content_t "/custom/path(/.*)?"',
  path    => '/bin:/usr/bin/:/sbin:/usr/sbin',
  require => Package['policycoreutils-python'],
}

package { 'policycoreutils-python':
  ensure => installed,
}

exec { 'restorecon_apache':
  command => 'restorecon -Rv /apache_spec',
  path    => '/bin:/usr/bin/:/sbin:/usr/sbin',
  before  => Class['Apache::Service'],
  require => Class['apache'],
}

class { 'apache': }

host { 'test.server':
  ip => '127.0.0.1',
}

file { '/custom/path':
  ensure => directory,
}

file { '/custom/path/include':
  ensure  => present,
  content => '#additional_includes',
}

apache::vhost { 'test.server':
  docroot             => '/custom/path',
  additional_includes => '/custom/path/include',
}
```

You must set the contexts using `semanage fcontext` instead of `chcon` because Puppet's `file` resources reset the values' context in the database if the resource doesn't specify it.

### Ubuntu 10.04

The [`apache::vhost::WSGIImportScript`][] parameter creates a statement inside the virtual host that is unsupported on older versions of Apache, causing it to fail. This will be remedied in a future refactoring.

### Ubuntu 16.04
The [`apache::mod::suphp`][] class is untested since repositories are missing compatible packages.

## Development

### Contributing

[Puppet][] modules on the [Puppet Forge][] are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad hardware, software, and deployment configurations that Puppet is intended to serve.

We want to make it as easy as possible to contribute changes so our modules work in your environment, but we also need contributors to follow a few guidelines to help us maintain and improve the modules' quality.

For more information, please read the complete [module contribution guide][].

### Testing

This project contains tests for both [rspec-puppet][] and [beaker-rspec][] to verify functionality. For detailed information on using these tools, please see their respective documentation.

#### Testing quickstart: Ruby > 1.8.7

```
gem install bundler
bundle install
bundle exec rake spec
bundle exec rspec spec/acceptance
RS_DEBUG=yes bundle exec rspec spec/acceptance
```

#### Testing quickstart: Ruby = 1.8.7

```
gem install bundler
bundle install --without system_tests
bundle exec rake spec
```
