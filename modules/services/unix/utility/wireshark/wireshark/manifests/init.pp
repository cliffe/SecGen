class wireshark {
	include apt

	if $::os["name"] == "Debian" {
		apt::source { 'ftp_debian_jessie':
		  location => 'http://ftp.uk.debian.org/debian/',
			release  => 'jessie',
		  repos    => 'main contrib non-free',
			before   => Package['wireshark'],
			notify   => Exec['apt_update'],
		}

		apt::source { 'security_debian_jessie_updates':
			location => 'http://security.debian.org/',
			release  => 'jessie/updates',
			repos    => 'main contrib non-free',
			before   => Package['wireshark'],
			notify   => Exec['apt_update'],
		}

		apt::source { 'ftp_debian_jessie-updates':
		  location => 'http://ftp.uk.debian.org/debian/',
			release  => 'jessie-updates',
		  repos    => 'main contrib non-free',
			before   => Package['wireshark'],
			notify   => Exec['apt_update'],
		}
	}

	package { 'wireshark':
		ensure => present,
	  before => File["/home/charlie/wireshark"],
	}

	file { '/home/charlie/wireshark':
		ensure => 'link',
		target => '/usr/bin/wireshark',
  }
}
