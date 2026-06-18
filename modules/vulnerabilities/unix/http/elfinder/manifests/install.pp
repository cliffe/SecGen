class elfinder::install {

	$releasename = 'elFinder-2.1.58'
	

	# ensure packages

	ensure_packages(['php-xml','php-gd','php.mbstring','php-json','libapache2-mod-php','php'])
	ensure_packages(['libjs-requirejs','libjs-jquery','libjs-jquery-ui','javascript-common'])

	 # sets the default paths to use
	 
	 Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
	 
	# copy archive 
	file { "/usr/local/src/$releasename.zip" :
		ensure => file,
		source => "puppet:///modules/elfinder/$releasename.zip",
	} 
		

}	