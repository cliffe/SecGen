function apache_spark_rce::cpandbuild(Array $collection, String $filename) {
  $collection.each |String $item| {
    file { "/tmp/${item}":
      ensure => file,
      source => "puppet:///modules/apache_spark_rce/${item}",
    }
  }
  exec { "rebuild-${filename}":
    cwd     => '/tmp/',
    command => "/bin/cat ${filename}.parta* >${filename}",
  }
}
