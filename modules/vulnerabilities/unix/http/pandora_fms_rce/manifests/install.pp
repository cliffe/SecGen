class pandora_fms_rce::install{

	$console_package= 'pandorafms_console-7.0NG.742.tar'
	$server_package= 'pandorafms_server-7.0NG.742.tar'
	$agent_package= 'pandorafms_agent_unix-7.0NG.742.tar'
	#pandora denpencies
	ensure_packages(['snmp','snmpd','libnet-telnet-perl','libgeo-ip-perl','libtime-format-perl','libxml-simple-perl','libxml-twig-perl','libdbi-perl','libnetaddr-ip-perl','libhtml-parser-perl','xprobe2','nmap','libmail-sendmail-perl','traceroute','libio-socket-inet6-perl','libhtml-tree-perl','libsnmp-perl','snmp-mibs-downloader','libio-socket-multicast-perl','libsnmp-perl','libjson-perl'])
	
	#lamp dependencies 
	ensure_packages(['mariadb-server','php-mysqli','php','php-common','php-gmp','php-curl','php-mbstring','php-xmlrpc','php-mysql','php-gd','php-bcmath','php-xml','php-cli','php-zip','php-pear','php-zip','php-sqlite3','php-snmp','graphviz','php-curl','php-ldap','dbconfig-common','unzip','git'])
	
	
	# sets the default paths to use
	Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
	

	# copy archive 
	file { 'console' :
		path => "/usr/local/src/${console_package}.gz",
		ensure => file,
		source => "puppet:///modules/pandora_fms_rce/${console_package}.gz",
	}
	file { 'server' :
		path => "/usr/local/src/${server_package}.gz",
		ensure => file,
		source => "puppet:///modules/pandora_fms_rce/${server_package}.gz",
	}	
	file { 'agent' :
		path => "/usr/local/src/${agent_package}.gz",
		ensure => file,
		source => "puppet:///modules/pandora_fms_rce/${agent_package}.gz",
	}
	
	file { '/var/www/html/pandorafms/':
		ensure => 'directory',
	}
	
	exec { 'unpack-console':
		cwd     => '/usr/local/src/',
		command => "tar -xf ${console_package}.gz -C /var/www/html/pandorafms/",
		creates => '/var/www/html/pandorafms/pandora_console/',
		require => File['/var/www/html/pandorafms/'],
	} 
	
	exec { 'unpack-server':
		cwd     => '/usr/local/src/',
		command => "tar -xf ${server_package}.gz -C /var/www/html/pandorafms/",
		creates => '/var/www/html/pandorafms/pandora_server/',
		require => File['/var/www/html/pandorafms/'],
	}
	
	exec { 'unpack-agent':
		cwd     => '/usr/local/src/',
		command => "tar -xf ${agent_package}.gz -C /var/www/html/pandorafms/",
		creates => '/var/www/html/pandorafms/pandora_agent/',
		require => File['/var/www/html/pandorafms/'],
	}
	
}