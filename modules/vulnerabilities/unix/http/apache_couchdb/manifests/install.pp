class apache_couchdb::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $responsefile = 'installresponse'
  $packagename = 'couchdb_3.2.1_buster_amd64'
  $jsondb = 'sampledata.json'
  $password = $secgen_parameters['used_password'][0]

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  ensure_packages(['build-essential',
  'pkg-config',
  'erlang',
  'libicu-dev',
  'libmozjs-60-dev',
  'libcurl4-openssl-dev',
  'gnupg'])

  # copy archive
  file { "/usr/local/src/${packagename}.deb" :
    ensure => file,
    source => "puppet:///modules/apache_couchdb/${packagename}.deb",
  }
  -> file { "/usr/bin/${responsefile}" :
    ensure  => file,
    content => template("apache_couchdb/${responsefile}.erb"),
  }
  -> file { "/usr/bin/${jsondb}.json" :
    ensure  => file,
    content => template("apache_couchdb/${jsondb}.erb"),
  }
  #install couch db from deb file
  -> package {'couchdb-install':
    name         => $packagename,
    provider     => dpkg,
    source       => "/usr/local/src/${packagename}.deb",
    responsefile =>  $responsefile,
  }
}
