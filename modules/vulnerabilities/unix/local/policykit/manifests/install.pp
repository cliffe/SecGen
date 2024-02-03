class policykit::install {

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']

  # https://snapshot.debian.org/archive/debian/20190115T151622Z/pool/main/p/policykit-1/policykit-1_0.105-18_amd64.deb
  $repo_name = 'snapshot_repo'
  $repo_suite = 'buster main'
  $repo_components = '' #contrib

  $repo_url = "http://snapshot.debian.org/archive/debian/20180114T032446Z"
  $package_version = '0.105-18'
  # slightly newer
  # $repo_url = "http://snapshot.debian.org/archive/debian/20190101T025954Z"
  # $package_version = '0.105-23'

  /*
  file { "/etc/apt/sources.list.d/${repo_name}.list":
    ensure  => 'present',
    content => "deb [trusted=yes] ${repo_url} ${repo_suite} ${repo_components}",
  } ->

  exec { 'apt_update_policykit':
    command => '/usr/bin/apt-get update --fix-missing -o Acquire::Check-Valid-Until=false',
  } ->
  # using exec because all the packages need installing at once to resolve dependancies
  exec { 'apt_install_policykit':
    command => "/usr/bin/apt-get install -y --fix-missing --allow-unauthenticated libpolkit-agent-1-0=$package_version libpolkit-backend-1-0=$package_version libpolkit-gobject-1-0=$package_version policykit-1=$package_version",
  } ->


  exec { 'remove repo':
    command => "/bin/rm /etc/apt/sources.list.d/${repo_name}.list",
  }
  */


  file { '/tmp/libpolkit-gobject-1-0_0.105-18_amd64.deb':
    ensure => file,
    source => 'puppet:///modules/policykit/libpolkit-gobject-1-0_0.105-18_amd64.deb',
  }
  -> package { 'libpolkit-gobject':
    ensure   => installed,
    provider => dpkg,
    source   => '/tmp/libpolkit-gobject-1-0_0.105-18_amd64.deb'
  }
  -> file { '/tmp/libpolkit-agent-1-0_0.105-18_amd64.deb':
    ensure => file,
    source => 'puppet:///modules/policykit/libpolkit-agent-1-0_0.105-18_amd64.deb',
  }
  -> package { 'libpolkit-agent':
    ensure   => installed,
    provider => dpkg,
    source   => '/tmp/libpolkit-agent-1-0_0.105-18_amd64.deb'
  }
  -> file { '/tmp/libpolkit-backend-1-0_0.105-18_amd64.deb':
    ensure => file,
    source => 'puppet:///modules/policykit/libpolkit-backend-1-0_0.105-18_amd64.deb',
  }
  -> package { 'libpolkit-backend':
    ensure   => installed,
    provider => dpkg,
    source   => '/tmp/libpolkit-backend-1-0_0.105-18_amd64.deb'
  }
  -> file { '/tmp/policykit-1_0.105-18_amd64.deb':
    ensure => file,
    source => 'puppet:///modules/policykit/policykit-1_0.105-18_amd64.deb',
  }
  -> package { 'policykit':
    ensure   => installed,
    provider => dpkg,
    source   => '/tmp/policykit-1_0.105-18_amd64.deb'
  }

  # Leak a file containing a string/flag to /root/
  ::secgen_functions::leak_files { 'policykit-file-leak':
    storage_directory => '/root',
    leaked_filenames => $leaked_filenames,
    strings_to_leak => $strings_to_leak,
    leaked_from => "",
    mode => '0600'
  }
}
