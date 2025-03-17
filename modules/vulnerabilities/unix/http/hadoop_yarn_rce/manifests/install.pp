class hadoop_yarn_rce::install {
	$releasename = 'hadoop-3.3.4'
	$docroot= "/usr/local/hadoop"
	
	Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

	#install dependencies
	ensure_packages(['default-jdk','default-jre','ssh','rsync' ])
	
	# copy archive 
	file { "/usr/local/src/$releasename.tar.gz" :
		ensure => file,
		source => "puppet:///modules/hadoop_yarn_rce/$releasename.tar.gz",
	} ->
	#unzip
	exec {'unzip-hadoop':
		cwd => '/usr/local/src',
		command => "tar -xvzf ${releasename}.tar.gz -C /usr/local",
		creates => /usr/local/${releasename},			
	}->
	#rename folder
	exec {'rename-hadoop directory':
		cwd => '/usr/local',
		command => "mv ${releasename} hadoop",
		logoutput => true,
	}


}
