class codoforum_rce_authenticated::install {
	$releasename = 'codoforum-v-5-1'
	
	
	Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
	
	# install dependencies
	ensure_packages(['php-xml','php-gd','php.mbstring','php-json','libapache2-mod-php','php','mariadb-server','php-mysqli'])
	
    # copy and unzip archive
	file { "/usr/local/src/$releasename.zip" :
		ensure => file,
		source => "puppet:///modules/codoforum_rce_authenticated/$releasename.zip",
	} 


}