function drupal_850::cpandbuild(Array $collection, String $filename) {
  $collection.each |String $item| {
    file { "/tmp/${item}":
      ensure => file,
      source => "puppet:///modules/drupal_850/${item}",
    }
  }
  exec { "rebuild-${filename}":
    cwd     => '/tmp/',
    command => "/bin/cat ${filename}.parta* > ${filename}",
    creates => "/tmp/${filename}",
  }
}
