  #copies and unpacks vsftpd_234_backdoor saves it to usr/local/sbin and executes it for startup
  class vsftpd_234_backdoor::install {
    exec { 'unzip-vsftpd':
		command     => 'tar xzf vsftpd-2.3.4.tar.gz && mv vsftpd-2.3.4 /home/vagrant/vsftpd-2.3.4',
		path => '/bin',
		cwd         => "/mount/files/shell",
		creates     => "/home/vagrant/vsftpd-2.3.4/vsftpd",
		notify	 => Exec['make-vsftpd']
	}

	exec { 'make-vsftpd':
		command     => '/usr/bin/make',
		cwd         => "/home/vagrant/vsftpd-2.3.4",
		creates     => "/home/vagrant/vsftpd-2.3.4/vsftpd",
		notify	 => Exec['copy-vsftpd'],
		require     => Exec["unzip-vsftpd"],
	}


	exec { 'copy-vsftpd':
		command     => '/mount/files/shell/copyvsftpd.sh',
		cwd         => "/home/vagrant/vsftpd-2.3.4",
		creates     => "/usr/local/sbin/vsftpd",
		notify	 => User['ftp'],
		require     => Exec["make-vsftpd"],
	}

    user { 'ftp':
      ensure     => present,
      uid        => '507',
      gid        => 'root',
      shell      => '/bin/zsh',
      home       => '/var/ftp',
      notify	 => Exec['start-vsftpd'],
      require     => Exec["copy-vsftpd"],
      managehome => true,
    }

    exec { 'start-vsftpd':
		command     => '/mount/files/shell/startvsftpd.sh',
		require     => User["ftp"],
	}
}



