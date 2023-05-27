# Class: apache_spark_rce::install
# install process
# https://archive.apache.org/dist/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz
# https://www.scala-lang.org/download/2.12.10.html
class apache_spark_rce::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $modulename = 'apache_spark_rce'

  # Install required packages
  # NOTE: once Debian updates insert scala 2.12+ into statement
  ensure_packages(['openjdk-11-jdk'], { ensure => 'installed'})

  $scaladeb = 'scala-2.12.10.deb'
  $releasename = 'spark-3.1.2-bin-hadoop3.2.tgz'
  $shortrelease = 'spark-3.1.2-bin-hadoop3.2'

  $scalapart = ["${scaladeb}.partaa",
    "${scaladeb}.partab",
    "${scaladeb}.partac"]

  $sparkpart = ["${releasename}.partaa",
    "${releasename}.partab",
    "${releasename}.partac",
    "${releasename}.partad",
    "${releasename}.partae"]

  $pkgtobuild = [[$scalapart, $scaladeb], [$sparkpart, $releasename]]
  $pkgtobuild.each |Array $pkg| {
    apache_spark_rce::cpandbuild($pkg[0], $pkg[1])
  }

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $user = $secgen_parameters['unix_username'][0]

  $user_home = "/home/${user}"

  # Create user
  user { $user:
    ensure     => present,
    home       => $user_home,
    managehome => true,
  }

  # We run older versions of debian, for now source from local deb file
  package { 'scala':
    ensure   => latest,
    provider => apt,
    source   => "/tmp/${scaladeb}",
  }

  exec { 'unpack-spark':
    cwd     => '/tmp',
    command => "tar -xf ${releasename}",
    creates => '/tmp/spark'
  }
  -> exec { 'move-spark':
    cwd     => '/tmp',
    command => "mv /tmp/${shortrelease} /usr/local/spark/",
    creates => '/usr/local/spark',
  }
  -> exec { 'chown-spark':
    command => "chown -R ${user} /usr/local/spark/",
  }
}
