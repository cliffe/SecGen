# chocolatey::install - Private class used for install of Chocolatey
class chocolatey::install {
  assert_private()

  $download_url = $::chocolatey::chocolatey_download_url
  $unzip_type   = $::chocolatey::use_7zip ? {
    true      => '7zip',
    default   => 'windows'
  }

  # These are specifically necessary to ensure that we know the path
  # has been updated in the current run. They are typically a noop.
  windows_env { 'chocolatey_ChocolateyInstall_env':
    ensure    => present,
    variable  => 'ChocolateyInstall',
    mergemode => 'clobber',
    value     => $::chocolatey::choco_install_location,
    notify    => Exec['install_chocolatey_official'],
  }

  windows_env { 'chocolatey_PATH_env':
    ensure    => present,
    variable  => 'PATH',
    mergemode => 'prepend',
    value     => "${::chocolatey::choco_install_location}\\bin",
    notify    => Exec['install_chocolatey_official'],
  }

  exec { 'install_chocolatey_official':
    command     => template('chocolatey/InstallChocolatey.ps1.erb'),
    creates     => "${::chocolatey::choco_install_location}\\bin\\choco.exe",
    provider    => powershell,
    timeout     => $::chocolatey::choco_install_timeout_seconds,
    logoutput   => $::chocolatey::log_output,
    environment => ["ChocolateyInstall=${::chocolatey::choco_install_location}"]
  }
}
