$secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

$secgen_domain          = $secgen_parameters['domain'][0]
$strings_to_leak = $secgen_parameters['strings_to_leak']
$uri             = $secgen_parameters['uri'][0]

# Parse cert bundle JSON from self_signed_cert generator
$raw_cert_bundle = $secgen_parameters['cert_bundle'][0]
if $raw_cert_bundle and $raw_cert_bundle != '' {
  $cert_bundle = parsejson($raw_cert_bundle)
  $cert_pem    = $cert_bundle['cert_pem']
  $key_pem     = $cert_bundle['key_pem']
} else {
  $cert_pem = undef
  $key_pem  = undef
}

# Extract path from URI by splitting on '/'
# e.g. http://web.netseclab.co.uk/a3f9bc72de1408f5/ -> a3f9bc72de1408f5
if $uri and $uri != '' {
    if $uri =~ /\/$/ {
      $normalised_uri = $uri
    } else {
      $normalised_uri = "${uri}/"
    }
    $uri_parts = split($normalised_uri, '/')
    $uri_path  = $uri_parts[3]
} else {
  $uri_path = undef
}

$docroot = '/var/www/html'

class { 'apache':
  mpm_module    => 'prefork',
  default_vhost => false,
}

include apache::mod::ssl

exec { 'apache2-systemd-reload':
  command => 'systemctl daemon-reload; systemctl enable apache2',
  path    => ['/usr/bin', '/bin', '/usr/sbin'],
}

# Write cert and key to disk if provided
if $cert_pem and $key_pem {
  file { '/etc/ssl/certs/secgen-apache.crt':
    ensure  => file,
    content => $cert_pem,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/etc/ssl/private/secgen-apache.key':
    ensure  => file,
    content => $key_pem,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
  }

  $ssl_cert = '/etc/ssl/certs/secgen-apache.crt'
  $ssl_key  = '/etc/ssl/private/secgen-apache.key'
  $ssl_require = [
    File['/etc/ssl/certs/secgen-apache.crt'],
    File['/etc/ssl/private/secgen-apache.key'],
  ]
} else {
  $ssl_cert    = undef
  $ssl_key     = undef
  $ssl_require = []
}

# HTTP vhost — port 80
apache::vhost { "${domain}-http":
  servername => $secgen_domain,
  port       => '80',
  docroot    => $docroot,
}

# HTTPS vhost — port 443, only configured if cert bundle provided
# No HSTS header — student adds this in Week 11 MitM lab
if $cert_pem and $key_pem {
  apache::vhost { "${domain}-https":
    servername => $secgen_domain,
    port       => '443',
    docroot    => $docroot,
    ssl        => true,
    ssl_cert   => $ssl_cert,
    ssl_key    => $ssl_key,
    require    => $ssl_require,
  }
}

# Host strings_to_leak content at the path extracted from uri
# Content is written as-is — plain text, HTML, whatever was passed in
if $uri_path and $strings_to_leak and $strings_to_leak[0] {
  file { "${docroot}/${uri_path}":
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0755',
  }

  file { "${docroot}/${uri_path}/index.html":
    ensure  => file,
    content => $strings_to_leak[0],
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
    require => File["${docroot}/${uri_path}"],
  }
}