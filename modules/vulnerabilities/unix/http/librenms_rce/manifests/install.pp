class librenms_rce::install {
	$releasename = 'librenms-1.43'
	$docroot = '/opt/librenms' 
	# sets the default paths to use
	Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
	#TESTING ONLY make sure to run apt-get update before running module
	#TODO remove package redundencies 
	#ensure_packages(['acl','composer','curl','fping','git','graphviz','imagemagick','mariadb-server','mtr-tiny','nginx-full','nmap','php7.3-cli','php7.3-curl','php7.3-fpm','php7.3-gd','php7.3-json','php7.3-mysql','php7.3-snmp','php7.3-xml','php7.3-zip','php7.3-mbstring','php-mysqli','python-memcache','python-mysqldb','rrdtool','snmp','snmpd','whois','php-xml','php-gd','php-mbstring','php-json','libapache2-mod-php','php','python3-pymysql','python3-dotenv','python3-redis','python3-setuptools','software-properties-common'])
	#ensure_packages(['php','php-common','php-cli','php-fpm','php-json','php-pdo','php-mysql','php-zip','php-gd','php-mbstring','php-curl','php-xml','php-pear','php-bcmath'])

	ensure_packages(['software-properties-common'])
	ensure_packages(['curl','acl','composer','fping','git','graphviz','imagemagick','mariadb-server','mtr-tiny','nginx-full','nmap','python-memcache','python-mysqldb','python-pip','rrdtool','snmp','snmpd','whois'])	
	ensure_packages(['php-common','php-cli','php-fpm','php-json','php-pdo','php-mysql','php-zip','php-gd','php-mbstring','php-curl','php-xml','php-pear','php-bcmath'])

	# copy and unzip archive
	file {  'librenms':
		ensure => file,
		path  => "/usr/local/src/${releasename}.zip",
		source => "puppet:///modules/librenms_rce/${releasename}.zip"
	} 	
	exec { 'unzip-librenms':
		cwd => '/usr/local/src',
		command => "unzip ${releasename}.zip -d /opt",
		require => File['librenms']
	} ->
	exec {'rename-directory':
        cwd => '/opt',
        command => "mv ${releasename} librenms",
        logoutput => true
    }
	
	
}