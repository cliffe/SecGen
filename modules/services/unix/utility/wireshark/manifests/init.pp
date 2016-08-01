class wireshark {
	include apt

	if $::operatingsystem == "Debian" {
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
		ensure => present
  }
}
