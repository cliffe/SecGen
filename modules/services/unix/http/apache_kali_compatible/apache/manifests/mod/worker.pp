# == Class: apache::mod::worker
#
#
# === Parameters
#
#  [*startservers*]
#   (optional) The number of child server processes created on startup
#   Defaults is '2'
#
#  [*maxclients*]
#   (optional) The max number of simultaneous requests that will be served.
#   This is the old name and is still supported. The new name is
#   MaxRequestWorkers as of 2.3.13.
#   Default is '150'
#
#  [*minsparethreads*]
#   (optional) Minimum number of idle threads to handle request spikes.
#   Default is '25'
#
#  [*maxsparethreads*]
#   (optional) Maximum number of idle threads.
#   Default is '75'
#
#  [*threadsperchild*]
#   (optional) The number of threads created by each child process.
#   Default is '25'
#
#  [*maxrequestsperchild*]
#   (optional) Limit on the number of connectiojns an individual child server
#   process will handle. This is the old name and is still supported. The new
#   name is MaxConnectionsPerChild as of 2.3.9+.
#   Default is '0'
#
#  [*serverlimit*]
#   (optional) With worker, use this directive only if your MaxRequestWorkers
#   and ThreadsPerChild settings require more than 16 server processes
#   (default). Do not set the value of this directive any higher than the
#   number of server processes required by what you may want for
#   MaxRequestWorkers and ThreadsPerChild.
#   Default is '25'
#
#  [*threadlimit*]
#   (optional) This directive sets the maximum configured value for
#   ThreadsPerChild for the lifetime of the Apache httpd process.
#   Default is '64'
#
#  [*listenbacklog*]
#    (optional) Maximum length of the queue of pending connections.
#    Defaults is '511'
#
#  [*apache_version*]
#   (optional)
#   Default is $::apache::apache_version
#
class apache::mod::worker (
  $startservers        = '2',
  $maxclients          = '150',
  $minsparethreads     = '25',
  $maxsparethreads     = '75',
  $threadsperchild     = '25',
  $maxrequestsperchild = '0',
  $serverlimit         = '25',
  $threadlimit         = '64',
  $listenbacklog       = '511',
  $apache_version      = undef,
) {
  include ::apache
  $_apache_version = pick($apache_version, $apache::apache_version)

  if defined(Class['apache::mod::event']) {
    fail('May not include both apache::mod::worker and apache::mod::event on the same node')
  }
  if defined(Class['apache::mod::itk']) {
    fail('May not include both apache::mod::worker and apache::mod::itk on the same node')
  }
  if defined(Class['apache::mod::peruser']) {
    fail('May not include both apache::mod::worker and apache::mod::peruser on the same node')
  }
  if defined(Class['apache::mod::prefork']) {
    fail('May not include both apache::mod::worker and apache::mod::prefork on the same node')
  }
  File {
    owner => 'root',
    group => $::apache::params::root_group,
    mode  => $::apache::file_mode,
  }

  # Template uses:
  # - $startservers
  # - $maxclients
  # - $minsparethreads
  # - $maxsparethreads
  # - $threadsperchild
  # - $maxrequestsperchild
  # - $serverlimit
  # - $threadLimit
  # - $listenbacklog
  file { "${::apache::mod_dir}/worker.conf":
    ensure  => file,
    content => template('apache/mod/worker.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }

  case $::osfamily {
    'redhat': {

      if versioncmp($_apache_version, '2.4') >= 0 {
        ::apache::mpm{ 'worker':
          apache_version => $_apache_version,
        }
      }
      else {
        file_line { '/etc/sysconfig/httpd worker enable':
          ensure  => present,
          path    => '/etc/sysconfig/httpd',
          line    => 'HTTPD=/usr/sbin/httpd.worker',
          match   => '#?HTTPD=/usr/sbin/httpd.worker',
          require => Package['httpd'],
          notify  => Class['apache::service'],
        }
      }
    }

    'debian', 'freebsd': {
      ::apache::mpm{ 'worker':
        apache_version => $_apache_version,
      }
    }
    'Suse': {
      ::apache::mpm { 'worker':
        apache_version => $apache_version,
        lib_path       => '/usr/lib64/apache2-worker',
      }
    }

    'gentoo': {
      ::portage::makeconf { 'apache2_mpms':
        content => 'worker',
      }
    }
    default: {
      fail("Unsupported osfamily ${::osfamily}")
    }
  }
}
