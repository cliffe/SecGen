function gitlab_13102::cpandbuild(Array $collection, String $filename) {
  $collection.each |String $item| {
    file { "/tmp/${item}":
      ensure => file,
      source => "puppet:///modules/gitlab_13102/${item}",
    }
  }
  exec { "rebuild-${filename}":
    cwd     => '/tmp/',
    command => "/bin/cat ${filename}.parta* > ${filename}",
    creates => "/tmp/${filename}",
  }
}
