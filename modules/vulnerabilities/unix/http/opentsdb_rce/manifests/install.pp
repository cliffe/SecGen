# Class: opentsdb_rce::install
# install process for opentsdb
#
class opentsdb_rce::install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $modulename = 'opentsdb_rce'
  $releasename = 'hbase-0.98.24-hadoop2-bin.tar.gz'
  $splits = ["${releasename}.partaa",
  "${releasename}.partab"]

  $jdkhome='\/usr\/lib\/jvm\/java-8-openjdk-amd64\//'

  $splits.each |String $split| {
    file { "/tmp/${split}":
      ensure => file,
      source => "puppet:///modules/${modulename}/${split}",
    }
  }

  # This generates a repo file so we can get packages from debian stretch
  file { '/etc/apt/sources.list.d/stretch.list':
    ensure => file,
    source => "puppet:///modules/${modulename}/stretch.list"
  }
  -> exec { 'update-packages':
    command => 'apt update'
  }
  -> package { 'install-jdk8':
    ensure => 'installed',
    name   => 'openjdk-8-jdk',
  }
  -> package { 'gnuplot':
    ensure => 'installed',
    name   => 'gnuplot',
  }

  exec { 'rebuild-archive':
    cwd     => '/tmp/',
    command => "cat ${releasename}.parta* >/usr/local/share/${releasename}",
  }
  -> exec { 'extract-hbase':
    cwd     => '/usr/local/share/',
    command => 'tar -xvf hbase-0.98.24-hadoop2-bin.tar.gz',
  }
  -> exec { 'chmod-hbase':
    cwd     => '/usr/local/share/',
    command => 'chmod 755 -R hbase-0.98.24-hadoop2'
  }
  -> exec { 'set-javahome':
    cwd     => '/usr/local/share/hbase-0.98.24-hadoop2/',
    command => "sed -i 's/# export JAVA_HOME=\/usr\/java\/jdk1.6.0\// export JAVA_HOME=${jdkhome}' conf/hbase-env.sh",
  }

  file { '/tmp/opentsdb-2.3.0_all.deb':
    ensure => file,
    source => "puppet:///modules/${modulename}/opentsdb-2.3.0_all.deb",
  }
  -> package { 'opentsdb':
    ensure   => 'installed',
    provider => 'dpkg',
    source   => '/tmp/opentsdb-2.3.0_all.deb'
  }
  -> exec { 'replace-service-dirs':
    command => "sed -i '/\JDK_DIRS=\"/a /usr/lib/jvm/java-8-oracle ${jdkhome} \ /usr/lib/jvm/java-8-openjdk /usr/lib/jvm/java-8-openjdk-i386/ \' /etc/init.d/opentsdb"
  }
  -> file { '/etc/systemd/system/hbase.service':
    ensure => file,
    source => "puppet:///modules/${modulename}/hbase.service"
  }
  -> file { '/etc/systemd/system/tsd.service':
    ensure => file,
    source => "puppet:///modules/${modulename}/tsd.service"
  }
  -> exec { 'reload-systemd-daemons':
    command => 'systemctl daemon-reload'
  }
}
