# == Class: php2shell_rce::install
#
# Serves a trivial PHP page from the unpatched PHP 7.4 (php7_vulnerable) via
# lighttpd + php-cgi, and leaks a flag to capture after code execution. The
# page is deliberately minimal: the vulnerability is in the interpreter, not
# the page.

class php2shell_rce::install {

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port             = $secgen_parameters['port'][0]
  $strings_to_leak  = $secgen_parameters['strings_to_leak']
  $leaked_filenames = $secgen_parameters['leaked_filenames']

  $docroot = '/var/www/html'

  ensure_packages(['lighttpd'], { ensure => 'installed' })

  file { ['/var/www', $docroot]:
    ensure => directory,
    mode   => '0755',
  }
  -> file { "${docroot}/index.php":
    ensure => file,
    source => 'puppet:///modules/php2shell_rce/index.php',
    mode   => '0644',
  }

  # lighttpd serves .php through the vulnerable php-cgi binary.
  file { '/etc/lighttpd/lighttpd.conf':
    ensure  => file,
    content => template('php2shell_rce/lighttpd.conf.erb'),
    mode    => '0644',
    require => [Package['lighttpd'], File["${docroot}/index.php"]],
    notify  => Service['lighttpd'],
  }

  # A flag to capture once code execution is achieved.
  ::secgen_functions::leak_files { 'php2shell-flag-leak':
    storage_directory => '/root',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'root',
    group             => 'root',
    mode              => '0600',
    leaked_from       => 'php2shell_rce',
  }
}
