# Class: tikiwiki_cal_rce::tiki_install
# Provide automation for the web installer process
#
class tikiwiki_cal_rce::tiki_install {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  # we need a file to be present called local.php in the db directory
  # then we can generate the tables through the console.php script
  exec { 'tiki-db-connection':
    command   => "curl -d 'db=mysqli&host=localhost&name=tikiwiki&user=user&pass=demo&resetdb=y&force_utf8=y&dbinfo=Continue&lang=en&install_step=4' http://localhost/tiki-install.php",
    provider  => 'shell',
    logoutput => true
  }
  -> exec { 'generate-tiki-db':
    cwd     => '/var/www/tiki-14.1/',
    command => 'php console.php database:install'
  }
  -> exec { 'tiki-change-admin':
    command   => "curl -d 'oldpass=admin&new_user_validation=y&user=admin&pass=password&pass2=password&email=tikiuser%40email.com&change=Change' http://localhost/tiki-change_password.php",
    provider  => 'shell',
    logoutput => true
  }
  -> file { '/var/www/tiki-14.1/profiles/':
    ensure => directory,
  }
  -> file { '/var/www/tiki-14.1/profiles/Calendar.yml':
    ensure => present,
    source => 'puppet:///modules/tikiwiki_cal_rce/Calendar.yml',
  }
  -> exec { 'tiki-enable-calendar':
    cwd     => '/var/www/tiki-14.1/',
    command => 'php console.php profile:apply Calendar profiles/'
  }
}
