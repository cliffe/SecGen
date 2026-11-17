# Installs the standalone capa release (rules embedded) as /usr/local/bin/capa.
class capa::install {
  Exec { path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'] }

  $version = 'v10.0.0'
  $archive = "capa-${version}-linux.zip"
  $sha256  = '96cb5115f495024a478b0e9f9f77f9027058155589235fbd4c50e7382055fcca'

  ensure_packages(['wget', 'unzip'])

  file { '/opt/capa':
    ensure => directory,
    mode   => '0755',
  }

  # Downloaded under a temporary name, so a failed checksum leaves nothing for 'creates' to find.
  exec { 'download capa':
    command  => "wget -q -O ${archive}.part https://github.com/mandiant/capa/releases/download/${version}/${archive} && echo '${sha256}  ${archive}.part' | sha256sum -c && mv ${archive}.part ${archive}",
    cwd      => '/opt/capa',
    provider => shell,
    creates  => "/opt/capa/${archive}",
    timeout  => 1800,
    require  => [File['/opt/capa'], Package['wget']],
  }

  exec { 'unzip capa':
    command => "unzip -o ${archive} capa && chmod 0755 capa",
    cwd     => '/opt/capa',
    provider => shell,
    creates => '/opt/capa/capa',
    require => [Exec['download capa'], Package['unzip']],
  }

  file { '/usr/local/bin/capa':
    ensure  => link,
    target  => '/opt/capa/capa',
    require => Exec['unzip capa'],
  }
}
