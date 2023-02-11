# Class: nanocms
# Install Process for nanocms
#
class nanocms_exec::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  # check php installed
  ensure_packages(['php'], { ensure => 'installed'})

  $releasename = 'nanocms_exec'
  file { "/tmp/${releasename}.zip":
    ensure => file,
    source => "puppet:///modules/nanocms_exec/${releasename}.zip"
  }
  -> exec { 'unpack-nanocms':
    cwd     => '/tmp',
    command => "unzip -o ${releasename} -d /var/www/nanocms",
    creates => "/var/www/nanocms/${releasename}"
  }
  -> exec { 'set-perms-nanocms':
    command => 'chmod -R 777 /var/www/nanocms/data/pages /var/www/nanocms/data/areas',
  }
}
