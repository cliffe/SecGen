# chocolatey::install - Private class used for install of Chocolatey
class chocolatey::install {
  assert_private()

  $download_url = $::chocolatey::chocolatey_download_url
  $unzip_type   = $::chocolatey::use_7zip ? {
    true      => '7zip',
    default   => 'windows'
  }

  registry_value { 'ChocolateyInstall environment value':
    ensure => present,
    path   => 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\ChocolateyInstall',
    type   => 'string',
    data   => $chocolatey::choco_install_location,
  }

  exec { 'install_chocolatey_official':
    command     => template('chocolatey/InstallChocolatey.ps1.erb'),
    creates     => "${::chocolatey::choco_install_location}\\bin\\choco.exe",
    provider    => powershell,
    timeout     => $::chocolatey::choco_install_timeout_seconds,
    logoutput   => $::chocolatey::log_output,
    environment => ["ChocolateyInstall=${::chocolatey::choco_install_location}"],
    # require     => Registry_value['ChocolateyInstall environment value'],
  }
}
