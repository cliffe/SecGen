# Class: opentsdb_rce::service
# Manage service behaviour and define additional opentsdb behaviour
#
class opentsdb_rce::service {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  service { 'hbase':
    ensure => running,
  }
  -> service { 'opentsdb':
    ensure => running,
  }
  -> exec { 'generate-hbase-tables':
    command => 'env COMPRESSION=NONE HBASE_HOME=/usr/local/share/hbase-0.98.24-hadoop2 /usr/share/opentsdb/tools/create_table.sh',
  }
  -> service { 'tsd':
    ensure => running,
  }
  -> exec { 'add-metric-to-opentsdb':
    cwd     => '/usr/share/opentsdb/bin/',
    command => 'bash tsdb mkmetric mysql.bytes_sent',
  }
  -> file { '/tmp/hbase-data':
    ensure => file,
    source => 'puppet:///modules/opentsdb_rce/hbase-data'
  }
  -> exec { 'add-hbase-data':
    cwd     => '/usr/share/opentsdb/bin/',
    command => 'bash tsdb import /tmp/hbase-data'
  }
}
