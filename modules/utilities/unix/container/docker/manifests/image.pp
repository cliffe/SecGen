# == Class: docker
#
# Module to install an up-to-date version of a Docker image
# from the registry
#
# === Parameters
# [*ensure*]
#   Whether you want the image present or absent.
#
# [*image*]
#   If you want the name of the image to be different from the
#   name of the puppet resource you can pass a value here.
#
# [*image_tag*]
#   If you want a specific tag of the image to be installed
#
# [*image_digest*]
#   If you want a specific content digest of the image to be installed
#
# [*docker_file*]
#   If you want to add a docker image from specific docker file
#
# [*docker_tar*]
#   If you want to load a docker image from specific docker tar
#
define docker::image(
  Optional[Pattern[/^(present|absent|latest)$/]] $ensure = 'present',
  Optional[Pattern[/^[\S]*$/]] $image                    = $title,
  Optional[String] $image_tag                            = undef,
  Optional[String] $image_digest                         = undef,
  Optional[Boolean] $force                               = false,
  Optional[String] $docker_file                          = undef,
  Optional[String] $docker_dir                           = undef,
  Optional[String] $docker_tar                           = undef,
) {
  include docker::params
  $docker_command = $docker::params::docker_command

  if $::osfamily == 'windows' {
    $update_docker_image_template = 'docker/windows/update_docker_image.ps1.erb'
    $update_docker_image_path = 'C:/Windows/Temp/update_docker_image.ps1'
    $exec_environment = 'PATH=C:/Program Files/Docker/'
    $exec_timeout = 3000
    $update_docker_image_owner = undef
    $exec_path = ['c:/Windows/Temp/', 'C:/Program Files/Docker/']
    $exec_provider = 'powershell'
  } else {
    $update_docker_image_template = 'docker/update_docker_image.sh.erb'
    $update_docker_image_path = '/usr/local/bin/update_docker_image.sh'
    $update_docker_image_owner = 'root'
    $exec_environment = 'HOME=/root'
    $exec_path = ['/bin', '/usr/bin']
    $exec_timeout = 0
    $exec_provider = undef
  }

  # Wrapper used to ensure images are up to date
  ensure_resource('file', $update_docker_image_path,
    {
      ensure  => $docker::params::ensure,
      owner   => $update_docker_image_owner,
      group   => $update_docker_image_owner,
      mode    => '0555',
      content => template($update_docker_image_template),
    }
  )

  if ($docker_file) and ($docker_tar) {
    fail translate('docker::image must not have both $docker_file and $docker_tar set')
  }

  if ($docker_dir) and ($docker_tar) {
    fail translate('docker::image must not have both $docker_dir and $docker_tar set')
  }

  if ($image_digest) and ($docker_file) {
    fail translate('docker::image must not have both $image_digest and $docker_file set')
  }

  if ($image_digest) and ($docker_dir) {
    fail translate('docker::image must not have both $image_digest and $docker_dir set')
  }

  if ($image_digest) and ($docker_tar) {
    fail translate('docker::image must not have both $image_digest and $docker_tar set')
  }

  if $force {
    $image_force   = '-f '
  } else {
    $image_force   = ''
  }

  if $image_tag {
    $image_arg     = "${image}:${image_tag}"
    $image_remove  = "${docker_command} rmi ${image_force}${image}:${image_tag}"
    $image_find    = "${docker_command} images -q ${image}:${image_tag}"
  } elsif $image_digest {
    $image_arg     = "${image}@${image_digest}"
    $image_remove  = "${docker_command} rmi ${image_force}${image}:${image_digest}"
    $image_find    = "${docker_command} images -q ${image}@${image_digest}"

  } else {
    $image_arg     = $image
    $image_remove  = "${docker_command} rmi ${image_force}${image}"
    $image_find    = "${docker_command} images -q ${image}"
  }
  if $::osfamily == 'windows' {
    $_image_find = "If (-not (${image_find}) ) { Exit 1 }"
  } else {
    $_image_find = "${image_find} | grep ."
  }

  if ($docker_dir) and ($docker_file) {
    $image_install = "${docker_command} build -t ${image_arg} -f ${docker_file} ${docker_dir}"
  } elsif $docker_dir {
    $image_install = "${docker_command} build -t ${image_arg} ${docker_dir}"
  } elsif $docker_file {
    if $::osfamily == windows {
      $image_install = "Get-Content ${docker_file} | ${docker_command} build -t ${image_arg} -"
    } else {
      $image_install = "${docker_command} build -t ${image_arg} - < ${docker_file}"
    }
  } elsif $docker_tar {
    $image_install = "${docker_command} load -i ${docker_tar}"
  } else {
    if $::osfamily == 'windows' {
      $image_install = "& ${update_docker_image_path} ${image_arg}"
    } else {
      $image_install = "${update_docker_image_path} ${image_arg}"
    }
  }

  if $ensure == 'absent' {
    exec { $image_remove:
      path        => $exec_path,
      environment => $exec_environment,
      onlyif      => $_image_find,
      provider    => $exec_provider,
      timeout     => $exec_timeout,
      logoutput   => true,
    }
  } elsif $ensure == 'latest' or $image_tag == 'latest' or $ensure == 'present' {
    exec { $image_install:
      unless      => $_image_find,
      environment => $exec_environment,
      path        => $exec_path,
      timeout     => $exec_timeout,
      returns     => ['0', '2'],
      require     => File[$update_docker_image_path],
      provider    => $exec_provider,
      logoutput   => true,
    }
  }

  Docker::Image <| title == $title |> -> Docker::Run <| image == $image_arg |>
}
