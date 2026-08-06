define hadoop_yarn_rce::hadoop_user ($username, $password, $hadoop_directory, $java_path, $strings_to_leak, $leaked_filenames){
	$home_directory ='/opt/hadoop'
	$bash_lines = [ "export JAVA_HOME=${java_path}",
				"export HADOOP_HOME=${hadoop_directory}",
				'export HADOOP_INSTALL=$HADOOP_HOME',
				'export HADOOP_MAPRED_HOME=$HADOOP_HOME',
				'export HADOOP_COMMON_HOME=$HADOOP_HOME', 
				'export HADOOP_HDFS_HOME=$HADOOP_HOME', 
				'export YARN_HOME=$HADOOP_HOME',
				'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native', 
				'export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin', 
				'export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"' ]
	#TODO cleanup
	::accounts::user { $username:
		shell      => '/bin/bash',
		password   => pw_hash($password, 'SHA-512', 'mysalt'),
		home =>	'/opt/hadoop',
		managehome => true,
		home_mode  => '0755',
	 }->
	 #edit bash
	$bash_lines.each |String $bash_lines| {
        file_line{"${home_directory}/.bashrc append ${bash_lines}":
        ensure => present,
        path   => "${home_directory}/.bashrc",
        line   => "${bash_lines}", 
        match =>"^(=*?)(${bash_lines})"
        }         
    }
	
	#generate-ssh-keys
	exec {'generate-ssh-keys':
		cwd => "${home_directory}",
		command => 'ssh-keygen -t rsa',
		logoutput => true
	} ->
	file {"${home_directory}/.ssh/authorized_keys":
		path => "${home_directory}/.ssh/authorized_keys",
		ensure => file, 
		source => "${home_directory}/.ssh/id_rsa.pub",
		notify => Exec['restart-ssh']
	}
	#restart ssh
	exec {'restart-ssh':
		command => 'service ssh restart',
		logoutput => true,
		notify => Exec['run-ssh']
	}
	exec {'run-ssh':
		command => 'ssh localhost',
		logoutput => true
	}
	
	
	  
	  # Leak strings in a text file in the users home directory
	  # ::secgen_functions::leak_files { "$username-file-leak":
		# storage_directory => "${home_directory}",
		# leaked_filenames  => $leaked_filenames,
		# strings_to_leak   => $strings_to_leak,
		# owner             => $username,
		# group             => $username,
		# mode              => '0600',
		# leaked_from       => "accounts_$username",
	  # }
	

					
    

	




}