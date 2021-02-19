class lime::install{
  Exec { path => ['/bin','/sbin','/usr/bin', '/usr/sbin'] }

  ensure_packages(['git','build-essential', "linux-headers-${facts['kernelrelease']}"])

  # exec { 'install linux-headers for LiME':
  #   command => "apt-get install linux-headers-${facts['kernelrelease']}",
  #   provider => 'shell',
  # }->
  exec {'clone LiME repo':
    command => 'git clone https://github.com/504ensicsLabs/LiME.git',
    cwd => '/root/'
  } ->
  exec {'make LiME kernel object':
    command => 'make',
    cwd => '/root/LiME/src/'
  }
}
