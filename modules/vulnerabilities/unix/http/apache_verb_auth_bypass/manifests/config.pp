# Serves a Basic-Auth-protected admin page (admin.php) whose access control is
# written with <Limit GET POST> rather than <LimitExcept GET POST>. A <Limit>
# block only covers the verbs it names (and the HEAD that Apache folds into
# GET), so any other method reaches the resource unauthenticated. Because PHP
# runs the page whatever the request method is, an arbitrary verb returns the
# full page without credentials, and - since PHP reads the query string whatever
# the method - the page's password-reset action can be driven the same way.
#
# apache is declared here (each SecGen module is its own Puppet catalog, so the
# required apache service module's resources are not visible from this run);
# php + libapache2-mod-php are installed here too, so no php service module
# (and no mysql) is pulled in.
class apache_verb_auth_bypass::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $strings_to_leak   = $secgen_parameters['strings_to_leak']
  $username          = $secgen_parameters['unix_username'][0]
  $password          = $secgen_parameters['used_password'][0]
  $reset_user        = $secgen_parameters['reset_target_username'][0]

  $docroot     = '/var/www/html'
  $htpasswd    = '/etc/apache2/.htpasswd'
  $auth_realm  = 'Admin Area'
  $admin_page  = "${docroot}/admin.php"
  $reset_tool  = '/usr/local/bin/panel_reset'
  $flag        = $strings_to_leak[0]

  Exec { path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'] }

  # mod_php needs the prefork MPM; TraceEnable Off so the only verbs that slip
  # past <Limit GET POST> are ones that actually execute the page (an arbitrary
  # method), rather than a TRACE that merely echoes the request.
  class { '::apache':
    default_vhost => false,
    mpm_module    => 'prefork',
    trace_enable  => 'Off',
  }

  package { ['php', 'libapache2-mod-php']:
    ensure  => installed,
    require => Package['httpd'],
  }

  # priority 05 keeps this vhost ahead of any default vhost a co-selected apache
  # module registers at priority 15 (see the Apache module's secgen_test notes).
  apache::vhost { 'verb_auth_bypass':
    priority => '05',
    port     => 80,
    docroot  => $docroot,
  }

  # htpasswd lives in apache2-utils (an apache2 recommends, not a hard dep).
  ensure_packages(['apache2-utils'])

  # Basic Auth credentials. The password is passed through an environment
  # variable so shell metacharacters in it cannot break the command.
  exec { 'verb_auth_bypass-htpasswd':
    command     => "htpasswd -bc ${htpasswd} ${username} \"\$VAB_PW\"",
    environment => ["VAB_PW=${password}"],
    provider    => shell,
    creates     => $htpasswd,
    logoutput   => false,
    require     => [Package['httpd'], Package['apache2-utils']],
  }

  file { $htpasswd:
    ensure  => file,
    owner   => 'root',
    group   => 'www-data',
    mode    => '0640',
    require => Exec['verb_auth_bypass-htpasswd'],
  }

  # A public landing page, so the site is not entirely behind auth - only
  # admin.php is protected.
  file { "${docroot}/index.html":
    ensure  => file,
    content => template('apache_verb_auth_bypass/index.html.erb'),
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
    require => Package['httpd'],
  }

  # The admin page: shows the first flag, and exposes a query-string-driven
  # password-reset action scoped to a single account.
  file { $admin_page:
    ensure  => file,
    content => template('apache_verb_auth_bypass/admin.php.erb'),
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
    require => [Package['httpd'], Package['php']],
  }

  # Over-privileged helper the admin panel calls through sudo: it resets exactly
  # one account's password (baked in at build time, never taken from the
  # request), so the attacker cannot steer it at root or any other user.
  file { $reset_tool:
    ensure  => file,
    content => template('apache_verb_auth_bypass/panel_reset.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  # www-data may run the reset helper as root without a password. Restricted to
  # the exact command, and the helper itself is fixed to one account.
  file { '/etc/sudoers.d/panel_reset':
    ensure  => file,
    content => "www-data ALL=(root) NOPASSWD: ${reset_tool}\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    require => File[$reset_tool],
  }

  # The misconfigured access control: <Limit GET POST> round admin.php
  # authenticates only those verbs; every other method is served unchallenged.
  apache::custom_config { 'verb_auth_bypass':
    content => template('apache_verb_auth_bypass/verb_auth_bypass.conf.erb'),
    require => [File[$admin_page], File[$htpasswd]],
  }
}
