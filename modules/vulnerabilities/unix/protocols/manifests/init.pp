class protocols ($protocols = "") {
	require java
	require gentoken
	class { 'wireshark':
		require => File["charlie_home"],
	}

	# Command to run:
	#FACTER_protocols="ex31:Lutescent","ex32:Olivaceous","ex33:Purpure","ex34:Titian" puppet agent --test

	# Setup all protocol servers
	$protocolsArray = split($protocols, '[,]')
	protocols::install_protocol { $protocolsArray:
			require => File['charlie_home'],
	}

	# Setup Protocol Class Encrypter
	file { "EncryptClass.java":
		path => "/root/EncryptClass.java",
		source => "puppet:///modules/protocols/loader/EncryptClass.java/",
		before => Exec['compile_class'],
	}
	exec { "compile_class":
		command => "javac EncryptClass.java",
		path => '/usr/bin/:/bin',
		cwd => '/root/',
		require => File['/root/EncryptClass.java'],
	}
	exec { "remove_encrypt":
		command => "rm Encrypt*",
		path => '/usr/bin/:/bin',
		cwd => '/root/',
		require => Protocols::Install_protocol[$protocolsArray],
	}

	# Setup Protocol Loader
	file { "RunProtocol.java":
		path => "/root/RunProtocol.java",
		source => "puppet:///modules/protocols/loader/RunProtocol.java/",
		before => Exec["compile_runProtocol"],
	}
	exec { "compile_runProtocol":
		command => "javac RunProtocol.java && rm RunProtocol.java",
		path => '/usr/bin/:/bin',
		cwd => '/root/',
		require => File['/root/RunProtocol.java'],
	}

  # Starts every protocols on start of VM
	if $::in_container == "true" {
		file { "startprotocol":
			path => "/etc/my_init.d/startprotocol",
			content => template("protocols/startprotocol.erb"),
			owner => root,
			group => root,
			mode => '0700',
		}
	} else {
	  file { "startprotocol":
	  	path => "/etc/init.d/startprotocol",
	  	content => template("protocols/startprotocol.erb"),
	  	owner => root,
	  	group => root,
	  	mode => '0700',
	  }
		exec {"update-rc.d startprotocol defaults":
			provider => "shell",
			cwd => "/etc/init.d",
			require => File["startprotocol"],
		}
	}

	# Create /root/tmp so nobody but root can access it
	file { "/root/tmp":
		ensure => directory,
		owner => "root",
		mode => '0700',
	}

	# Create Charlie Account
	group { "charlie":
		ensure => "present",
		before => User["charlie"],
	}
	user { 'charlie':
		ensure   => 'present',
		home     => '/home/charlie',
		groups   => "charlie",
		password => '$1$AS8jt.x2$er9sp1Bi8axWTEQnVK4Gg/',
		password_max_age => '99999',
    password_min_age => '0',
		shell    => '/bin/bash',
		gid      => '001',
		uid	 => '505',
	}
	file { "charlie_home":
		path    => "/home/charlie",
		owner   => "charlie",
		ensure  => directory,
		require => User['charlie'],
	}
}
