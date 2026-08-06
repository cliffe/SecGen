class hadoop_yarn_rce::hadoop {
	#$secgen_parameters=secgen_functions::get_parameters($::base64_inputs_file)
	#$account = parsejson($secgen_params['account'][0])
	$username='hadoop_user'#$username = $account['username']
	$password='password'#$password = $account['password']
	$strings_to_leak = ["this is a list of strings that are secrets / flags","another secret"]##$secgen_parameters['strings_to_leak']
	$leaked_filenames = ["flagtest"]##$secgen_parameters['leaked_filenames']
	$home_directory ='/opt/hadoop'
	$hadoop_directory= '/usr/local/hadoop'
	$java_version= "java-11-openjdk-amd64"
    $java_path ="/usr/lib/jvm/${java_version}"
	
	
	Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
	
	#create and configure hadoop user 
	::hadoop_yarn_rce::hadoop_user{"hadoop_yarn_rce_${username}":
		username => $username,		
		password   => pw_hash($password, 'SHA-512', 'mysalt'),
		hadoop_directory =>	$hadoop_directory,
		java_path => $java_path, 
		strings_to_leak => $strings_to_leak,
		leaked_filenames => $leaked_filenames,
		
	}->
	#create log directory 
	file {'/usr/local/hadoop/logs':
		ensure =>directory,
		owner  => $username,
		group  => $username,
		notify => Exec['chown-hadoop-permissions']
	}
	
	#update directory permissions
	exec {'chown-hadoop-permissions':
		command => "chown -R ${username}: ${hadoop_directory}",
		notify => Exec['execute .bashrc']
	}
	exec {'execute .bashrc':
		cwd => "${home_directory}",
		command => "source ~/.bashrc",
        user => "${username}",
		logoutput => true,
		notify => Exec["${home_directory} JAVA_JDK path"]		
	}
	exec {"${home_directory} JAVA_JDK path":
		cwd => "${home_directory}",
		command => "readlink -f \\\$\${java_version}",
		logoutput => true
	}->
	
    #update config files
	file { "${hadoop_directory}/etc/hadoop/core-site.xml":
		ensure  => present,
		content  => template('hadoop_yarn_rce/core-site.xml.erb')
	}->
	file { "${hadoop_directory}/etc/hadoop/hdfs-site.xml":
		ensure  => present,
		content  => template('hadoop_yarn_rce/hdfs-site.xml.erb')
	}->
    file { "${hadoop_directory}/etc/hadoop/mapred-site.xml":
		ensure  => present,
		content  => template('hadoop_yarn_rce/mapred-site.xml.erb')
	}->
	file_line{"${hadoop_directory}/etc/hadoop/hadoop-env.sh":
        ensure => present,
        path   => "${hadoop_directory}/etc/hadoop/hadoop-env.sh",
        line   => "export JAVA_HOME=${java_path} #JAVA_JDK directory", 
        match => 'export JAVA_HOME=',
		notify => Exec['run-JAVA_JDK path']
    }
		
	exec {'run-JAVA_JDK path':
		cwd => "${hadoop_directory}/etc/hadoop",
		command => "readlink -f \\\$\${java_version}",
		logoutput => true,
		notify => Exec['format-hadoop-filename']
	}
	
	exec {'format-hadoop-filename':
		cwd => "${hadoop_directory}",
		command => 'hadoop namenode -format',
		logoutput => true,
		notify => Exec['run-hadoop']
	}
	#start hadoop
	exec {'run-hadoop':
		cwd => "${hadoop_directory}",
		command => 'HADOOP_HOME/sbin/start-all.sh',
		logoutput => true
	}
	

}