class hackerbot::install {
  # $json_inputs = base64('decode', $::base64_inputs)
  # $secgen_parameters = parsejson($json_inputs)
  # $server_ip = $secgen_parameters['server_ip'][0]
  # $port = $secgen_parameters['port'][0]
  # $hackerbot_xml_configs = []
  # $hackerbot_lab_sheets = []

  file { '/opt/hackerbot':
    ensure  => directory,
    recurse => true,
    source  => 'puppet:///modules/hackerbot/opt_hackerbot',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
  }

  # System dependencies required for nokogiri and other gems
  $system_packages = [
    'zlibc',
    'zlib1g',
    'zlib1g-dev',
    'sshpass',
    'build-essential',
    'patch',
    'ruby-dev',
    'liblzma-dev',
    'libxml2-dev',
    'libxslt1-dev',
    'pkg-config'
  ]
  ensure_packages($system_packages)

  # Basic gems without nokogiri
  $gem_packages = ['nori', 'specific_install', 'programr', 'thwait']
  ensure_packages($gem_packages, {
    'provider' => 'gem',
    'require'  => Package['build-essential'],
  })

  # Remove problematic nokogiri installation first
  exec { 'remove nokogiri':
    command => 'gem uninstall nokogiri -a -x',
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    onlyif  => 'gem list | grep -q "^nokogiri"',
  }

  # Install nokogiri with system libraries and specific platform
  exec { 'install nokogiri':
    command => 'gem install nokogiri -v 1.15.5',
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    require => [
      Package[$system_packages],
      Exec['remove nokogiri']
    ],
    unless  => 'gem list | grep -q "^nokogiri"',
  }


  # Install cinch from GitHub
  exec { 'install cinch gem from github':
    command => 'sudo gem specific_install -l https://github.com/cliffe/cinch.git',
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    require => Package['specific_install'],
    unless  => 'gem list | grep -q "^cinch"',
  }
}
