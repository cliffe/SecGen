class ldap_server::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  
  $domain = $secgen_parameters['domain'][0]
  $organization = $secgen_parameters['organization'][0]
  $admin_password = $secgen_parameters['admin_password'][0]

  # Convert domain to LDAP DN format (e.g., "secgen.local" -> "dc=secgen,dc=local")
  $domain_parts = split($domain, '\.')
  $base_dn = $domain_parts.map |$part| { "dc=${part}" }.join(',')

  # Pre-seed debconf values to make slapd installation non-interactive
  # This prevents prompts during package installation
  exec { 'preseed-slapd':
    command => "/bin/echo \"slapd slapd/internal/generated_adminpw password ${admin_password}\" | debconf-set-selections && \
                /bin/echo \"slapd slapd/internal/adminpw password ${admin_password}\" | debconf-set-selections && \
                /bin/echo \"slapd slapd/password2 password ${admin_password}\" | debconf-set-selections && \
                /bin/echo \"slapd slapd/password1 password ${admin_password}\" | debconf-set-selections && \
                /bin/echo \"slapd slapd/domain string ${domain}\" | debconf-set-selections && \
                /bin/echo \"slapd shared/organization string ${organization}\" | debconf-set-selections && \
                /bin/echo 'slapd slapd/backend string MDB' | debconf-set-selections && \
                /bin/echo 'slapd slapd/purge_database boolean true' | debconf-set-selections && \
                /bin/echo 'slapd slapd/move_old_database boolean true' | debconf-set-selections && \
                /bin/echo 'slapd slapd/allow_ldap_v2 boolean false' | debconf-set-selections && \
                /bin/echo 'slapd slapd/no_configuration boolean false' | debconf-set-selections",
    unless  => '/usr/bin/dpkg -l | grep -q "^ii  slapd"',
    path    => ['/bin', '/usr/bin'],
  } ->
  # OpenLDAP Server and Utilities
  # Standalone LDAP daemon for serving directory information
  package { 'slapd':
    ensure  => installed,
  } ->
  # Ensure slapd service is running
  service { 'slapd':
    ensure  => running,
    enable  => true,
  }
  ->
  # LDAP command-line utilities for server management
  # Provides ldapsearch, ldapadd, ldapmodify, ldapdelete, etc.
  package { 'ldap-utils':
    ensure => installed,
  }

  # Wait for slapd to be fully configured before installing phpldapadmin
  Service['slapd']
  ->
  # phpLDAPadmin - Web-based LDAP administration interface
  # Provides a GUI for managing LDAP directory via Apache
  # This will automatically pull in php, php-ldap, php-xml, and libapache2-mod-php
  package { 'phpldapadmin':
    ensure => installed,
  }

  ->
  # Enable PHP module in Apache (version-agnostic)
  # Uses find to locate the installed PHP module and enables it
  exec { 'enable-php-module':
    command => '/bin/sh -c "/usr/bin/find /etc/apache2/mods-available -name php*.load -exec basename {} .load \; | /usr/bin/head -1 | /usr/bin/xargs /usr/sbin/a2enmod"',
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
  }
  ->
  # Ensure Apache includes conf-enabled directory (SecGen Apache module may not include this)
  exec { 'add-conf-enabled-to-apache':
    command => '/bin/echo "IncludeOptional conf-enabled/*.conf" >> /etc/apache2/apache2.conf',
    unless  => '/bin/grep -q "conf-enabled" /etc/apache2/apache2.conf',
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
  }
  ->
  # Enable phpldapadmin Apache configuration
  exec { 'enable-phpldapadmin-conf':
    command => '/usr/sbin/a2enconf phpldapadmin',
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
  }
  ->
  # Fix Apache 2.4 compatibility - update config to use modern syntax
  exec { 'fix-phpldapadmin-apache24-config':
    command => '/bin/sed -i "s/Order allow,deny/Require all granted/g; s/Allow from all//g" /etc/apache2/conf-available/phpldapadmin.conf',
    onlyif  => '/bin/grep -q "Order allow,deny" /etc/apache2/conf-available/phpldapadmin.conf',
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
  }
  ->
  # Restart Apache to apply configuration changes
  exec { 'restart-apache2-for-phpldapadmin':
    command => '/usr/sbin/service apache2 restart',
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
  }
  ->
  
  # Configure phpLDAPadmin base DN to match LDAP domain.
  # Replaces whatever value the package postinst wrote (dc=example,dc=com by default).
  # \$ is needed: a bare $servers in a double-quoted string is a Puppet variable.
  exec { 'configure-phpldapadmin-base-dn':
    command  => "sed -i \"s|^\\\$servers->setValue('server','base',array([^)]*));|\\\$servers->setValue('server','base',array('${base_dn}'));|\" /etc/phpldapadmin/config.php",
    unless   => "grep -qF \"setValue('server','base',array('${base_dn}'))\" /etc/phpldapadmin/config.php",
    provider => shell,
    path     => ['/bin', '/usr/bin'],
  }
  ->
  # Configure phpLDAPadmin to start auto-incrementing UIDs at 10000 and GIDs at 5000
  # This avoids conflicts with local system users (typically 1000-9999)
  # Inserts the configuration line before the closing ?> tag (with flexible whitespace matching)
  exec { 'configure-phpldapadmin-auto-uid':
    command => "/bin/sed -i \"/^?>\\s*$/i \\\$servers->setValue('auto_number','min',array('uidNumber'=>10000,'gidNumber'=>5000));\" /etc/phpldapadmin/config.php && echo 'phpLDAPadmin auto-UID configured'",
    onlyif  => [
      "/bin/test -f /etc/phpldapadmin/config.php",
      "/bin/grep -q '^?>' /etc/phpldapadmin/config.php"
    ],
    unless  => "/bin/grep -q \"uidNumber.*10000\" /etc/phpldapadmin/config.php",
    path    => ['/bin', '/usr/bin'],
  }
}
