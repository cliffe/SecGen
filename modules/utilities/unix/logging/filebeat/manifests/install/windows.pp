# filebeat::install::windows
#
# Download and install filebeat on Windows
#
# @summary A private class that installs filebeat on Windows
#
class filebeat::install::windows {
  # I'd like to use chocolatey to do this install, but the package for chocolatey is
  # failing for updates and seems rather unpredictable at the moment. We may revisit
  # that in the future as it would greatly simplify this code and basically reduce it to
  # one package resource with type => chocolatey....

  $filename = regsubst($filebeat::real_download_url, '^https?.*\/([^\/]+)\.[^.].*', '\1')
  $foldername = 'Filebeat'
  $zip_file = join([$filebeat::tmp_dir, "${filename}.zip"], '/')
  $install_folder = join([$filebeat::install_dir, $foldername], '/')
  $version_file = join([$install_folder, $filename], '/')

  Exec {
    provider => powershell,
  }

  if ! defined(File[$filebeat::install_dir]) {
    file { $filebeat::install_dir:
      ensure => directory,
    }
  }

  # Note: We can use archive for unzip and cleanup, thus removing the following two resources.
  # However, this requires 7zip, which archive can install via chocolatey:
  # https://github.com/voxpupuli/puppet-archive/blob/master/manifests/init.pp#L31
  # I'm not choosing to impose those dependencies on anyone at this time...
  archive { $zip_file:
    source       => $filebeat::real_download_url,
    cleanup      => false,
    creates      => $version_file,
    proxy_server => $filebeat::proxy_address,
  }

  exec { "unzip ${filename}":
    command => "\$sh=New-Object -COM Shell.Application;\$sh.namespace((Convert-Path '${filebeat::install_dir}')).Copyhere(\$sh.namespace((Convert-Path '${zip_file}')).items(), 16)", # lint:ignore:140chars
    creates => $version_file,
    require => [
      File[$filebeat::install_dir],
      Archive[$zip_file],
    ],
  }

  # Clean up after ourselves
  file { $zip_file:
    ensure  => absent,
    backup  => false,
    require => Exec["unzip ${filename}"],
  }

  # You can't remove the old dir while the service has files locked...
  exec { "stop service ${filename}":
    command => 'Set-Service -Name filebeat -Status Stopped',
    creates => $version_file,
    onlyif  => 'if(Get-WmiObject -Class Win32_Service -Filter "Name=\'filebeat\'") {exit 0} else {exit 1}',
    require => Exec["unzip ${filename}"],
  }

  exec { "rename ${filename}":
    command => "Remove-Item '${install_folder}' -Recurse -Force -ErrorAction SilentlyContinue;Rename-Item '${filebeat::install_dir}/${filename}' '${install_folder}'", # lint:ignore:140chars
    creates => $version_file,
    require => Exec["stop service ${filename}"],
  }

  exec { "mark ${filename}":
    command => "New-Item '${version_file}' -ItemType file",
    creates => $version_file,
    require => Exec["rename ${filename}"],
  }

  exec { "install ${filename}":
    cwd         => $install_folder,
    command     => './install-service-filebeat.ps1',
    refreshonly => true,
    subscribe   => Exec["mark ${filename}"],
  }
}
