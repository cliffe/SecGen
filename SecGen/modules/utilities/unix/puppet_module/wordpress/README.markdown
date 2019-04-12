# WordPress Module

## Overview

This will set up one or more installations of Wordpress 3.8 on Debian and Redhat style distributions.

## Capabilities

#### Installation includes:

- Configuration of WordPress DB connection parameters
- Generate secure keys and salts for `wp-config.php`.
- Optional creation of MySQL database/user/permissions.

#### Requires:

- Configuration of php-enabled webserver
- Configuration MySQL server
- PHP 5.3 or greater
- User specified by `wp_owner` must exist

## Parameters

### Class wordpress

* `install_dir`<br />
  Specifies the directory into which wordpress should be installed. Default: `/opt/wordpress`

* `install_url`<br />
  Specifies the url from which the wordpress tarball should be downloaded.  Default: `http://wordpress.org`

* `version`<br />
  Specifies the version of wordpress to install. Default: `3.8`

* `create_db`<br />
  Specifies whether to create the db or not. Default: `true`

* `create_db_user`<br />
  Specifies whether to create the db user or not. Default: `true`

* `db_name`<br />
  Specifies the database name which the wordpress module should be configured to use. Default: `wordpress`

* `db_host`<br />
  Specifies the database host to connect to. Default: `localhost`

* `db_user`<br />
  Specifies the database user. Default: `wordpress`

* `db_password`<br />
  Specifies the database user's password in plaintext. Default: `password`

* `wp_owner`<br />
  Specifies the owner of the wordpress files.  You must ensure this user exists as this module does not attempt to create it if missing. Default: `root`

* `wp_group`<br />
  Specifies the group of the wordpress files. Default: `0` (\*BSD/Darwin compatible GID)

* `wp_lang`<br />
  WordPress Localized Language. Default: ''

* `wp_plugin_dir`<br />
  WordPress Plugin Directory. Full path, no trailing slash. Default: WordPress Default

* `wp_additional_config`<br />
  Specifies a template to include near the end of the wp-config.php file to add additional options. Default: ''

* `wp_config_content`<br />
  Specifies the entire content for wp-config.php. This causes many of the other parameters to be ignored and allows an entirely custom config to be passed. It is recommended to use `wp_additional_config` instead of this parameter when possible.

* `wp_table_prefix`<br />
  Specifies the database table prefix. Default: wp_

* `wp_proxy_host`<br />
  Specifies a Hostname or IP of a proxy server for Wordpress to use to install updates, plugins, etc. Default: ''

* `wp_proxy_port`<br />
  Specifies the port to use with the proxy host.  Default: ''

* `wp_site_url`<br />
  If your WordPress server is behind a proxy, you might need to set the WP_SITEURL with this parameter.  Default: 'undef'

* `wp_multisite`<br />
  Specifies whether to enable the multisite feature. Requires `wp_site_domain` to also be passed. Default: `false`

* `wp_site_domain`<br />
  Specifies the `DOMAIN_CURRENT_SITE` value that will be used when configuring multisite. Typically this is the address of the main wordpress instance.  Default: ''

* `wp_debug`<br />
  Specifies the `WP_DEBUG` value that will control debugging. This must be true if you use the next two debug extensions. Default: 'false'

* `wp_debug_log`<br />
  Specifies the `WP_DEBUG_LOG` value that extends debugging to cause all errors to also be saved to a debug.log logfile insdie the /wp-content/ directory. Default: 'false'

* `wp_debug_display`<br />
  Specifies the `WP_DEBUG_DISPLAY` value that extends debugging to cause debug messages to be shown inline, in HTML pages. Default: 'false'

### Define wordpress::instance

* The parameters for `wordpress::instance` is exactly the same as the class `wordpress` except as noted below.
* The title will be used as the default value for `install_dir` unless otherwise specified.
* The `db_name` and `db_user` parameters are required.

### Other classes and defines

The classes `wordpress::app` and `wordpress::db` and defines `wordpress::instance::app` and `wordpress::instance::db` are technically private, but any PRs which add documentation and tests  so that they may be made public for multi-node deployments are welcome!

## Example Usage

Default single deployment (insecure; default passwords and installed as root):

```puppet
class { 'wordpress': }
```

Basic deployment (secure database password, installed as `wordpress` user/group.  NOTE: in this example you must ensure the `wordpress` user already exists):

```puppet
class { 'wordpress':
  wp_owner    => 'wordpress',
  wp_group    => 'wordpress',
  db_user     => 'wordpress',
  db_password => 'hvyH(S%t(\"0\"16',
}
```

Basic deployment of multiple instances (secure database password, installed as `wordpress` user/group):

```puppet
wordpress::instance { '/opt/wordpress1':
  wp_owner    => 'wordpress1',
  wp_group    => 'wordpress1',
  db_user     => 'wordpress1',
  db_name     => 'wordpress1',
  db_password => 'hvyH(S%t(\"0\"16',
}
wordpress::instance { '/opt/wordpress2':
  wp_owner    => 'wordpress2',
  wp_group    => 'wordpress2',
  db_user     => 'wordpress2',
  db_name     => 'wordpress2',
  db_password => 'bb69381b4b9de3a232',
}
```

Externally hosted MySQL DB:

```puppet
class { 'wordpress':
  db_user     => 'wordpress',
  db_password => 'hvyH(S%t(\"0\"16',
  db_host     => 'db.example.com',
}
```

Disable module's database/user creation (the database and db user must still exist with correct permissions):

```puppet
class { 'wordpress':
  db_user        => 'wordpress',
  db_password    => 'hvyH(S%t(\"0\"16',
  create_db      => false,
  create_db_user => false,
}
```

Install specific version of WordPress:

```puppet
class { 'wordpress':
  version => '3.4',
}
```

Install WordPress to a specific directory:

```puppet
class { 'wordpress':
  install_dir => '/var/www/wordpress',
}
```

Download `wordpress-${version}.tar.gz` from an internal server:

```puppet
class { 'wordpress':
  install_url => 'http://internal.example.com/software',
}
```

Configure wordpress to download updates and plugins through a proxy:

```puppet
class { 'wordpress':
  proxy_host => 'http://my.proxy.corp.com',
  proxy_port => '8080',
}
```

Enable the multisite wordpress feature:

```puppet
class { 'wordpress':
  wp_multisite   => true,
  wp_site_domain => 'blog.domain.com',
}
```

Add custom configuration to wp-config.php:

```puppet
class { 'wordpress':
  wp_additional_config => 'foo/wp-config-extra.php.erb',
}
```
