# == Define: ruby::bundle
#
# This resource runs [Bundler](http://bundler.io/) tasks. This resource was created to be sure that Bundler tasks would only be executed once their requirements were met by the `ruby::dev` class.
#
# === Parameters
#
# * *command*: (default is 'install') -
# This sets the command passed to the `bundler` executable. Not all bundler commands are currently supported. Only `exec`, `install` and `update` are currently supported.
# * *option*: (default is undefined) -
# This sets the options for the bundler command. Not all options are supported.
# * *rails_env*: (default is $ruby::params::rails_env) -
#  This parameter is used to set the `RAILS_ENV` environment variable, the default is to set it to production. This parameter is combined with the `environment` parameter to be passed to the `environment` parameter of the underlying `exec` resource that runs the bundler task.
# [*creates*]
# (default is undefined) Passed through to the underlying `exec` resource that runs the bundler task.
# [*cwd*]
# (default is undefined) Passed through to the underlying `exec` resource that runs the bundler task.
# [*environment*]
# (default is undefined) This parameter is combined with the `rails_env` parameter to be passed to the `environment` parameter of the underlying `exec` resource that runs the bundler task.
# [*user*]
# (default is undefined) Passed through to the underlying `exec` resource that runs the bundler task.
# [*group*]
# (default is undefined) Passed through to the underlying `exec` resource that runs the bundler task.
# [*logoutput*]
# (default is undefined) Passed through to the underlying `exec` resource that runs the bundler task.
# [*onlyif*]
# (default is undefined) Passed through to the underlying `exec` resource that runs the bundler task.
# [*path*]
# (default is undefined) The bundle executable has a minimum path requirement, if this parameter is left undefined, the default minimum path will be used. If a list of paths is provided, this list will be modified to be sure that it still meets the minimum path requirements for the bundle executable. This is then passed to the underlying `exec` resource that runs the bundle task.
# [*refresh*]
# (default is undefined) Passed through to the underlying `exec` resource that runs the bundler task.
# [*refreshonly*]
# (default is undefined) Passed through to the underlying `exec` resource that runs the bundler task.
# [*timeout*]
# (default is undefined) Passed through to the underlying `exec` resource that runs the bundler task.
# [*tries*]
# (default is undefined) Passed through to the underlying `exec` resource that runs the bundler task.
# [*try_sleep*]
# (default is undefined) Passed through to the underlying `exec` resource that runs the bundler task.
# [*unless*]
# (default is undefined) The `unless` parameter is only passed through to the underlying `exec` resource that runs the bundler task if the `ruby::bundler` resource `command` parameter is `exec`. For the `install` or `update` commands `unless` will be automatically set to, or overridden with, a command that makes the `ruby::bundle` resource idempotent.
#
# === Examples
#
# Using ruby::bundle to install gems:
#
#   ruby::bundle { 'install_app_gems':
#     option  => '--deployment',
#     cwd     => '/path/to/app',
#   }
#
define ruby::bundle
(
  $command      = 'install',
  $option       = undef,
  $rails_env    = undef,
  $multicore    = undef,
  $creates      = undef,
  $cwd          = undef,
  $environment  = undef,
  $user         = undef,
  $group        = undef,
  $logoutput    = undef,
  $onlyif       = undef,
  $path         = undef,
  $refresh      = undef,
  $refreshonly  = undef,
  $timeout      = undef,
  $tries        = undef,
  $try_sleep    = undef,
  $unless       = undef,
) {

  require ::ruby

  if $rails_env == undef {
    $rails_env_real = $ruby::params::rails_env
  } else {
    $rails_env_real = $rails_env
  }

  # ensure minimum path requirements for bundler
  if $path {
    $real_path = unique(flatten([$path, $ruby::params::minimum_path]))
  } else {
    $real_path = $ruby::params::minimum_path
  }

  # merge the environment and rails_env parameters
  if $environment {
    $real_environment = unique(flatten([$environment, ["RAILS_ENV=${rails_env_real}"]]))
  } else {
    $real_environment = "RAILS_ENV=${rails_env_real}"
  }

  if $multicore {
    if "${multicore}" == '0' or versioncmp($multicore,$::processorcount) >= 0 { #lint:ignore:only_variable_string
      $multicore_str = " --jobs ${::processorcount}"
    } else {
      $multicore_str = " --jobs ${multicore}"
    }
  } else {
    $multicore_str = undef
  }

  case $command {
    'install': {
      if $option {
        validate_re(
          $option,
          [
            '\s*--clean\s*',
            '\s*--deployment\s*',
            '\s*--gemfile=[a-zA-Z0-9\/\\:\.]+\s*',
            '\s*--path=[a-zA-Z0-9\/\\:\.]+\s*',
            '\s*--no-prune\s*',
            '\s*--without [[a-z0-9]+ ]+\s*',
          ],
          'Only bundler options supported for the install command are: clean, deployment, gemfile, path, without, and no-prune'
        )
        $real_command = "bundle ${command}${multicore_str} ${option}"
      } else {
        $real_command = "bundle ${command}${multicore_str}"
      }
      $real_unless  = 'bundle check'
    }
    'exec': {
      if $option {
        $real_command = "bundle ${command}${multicore_str} ${option}"
        $real_unless  = $unless
      } else {
        fail ('When given the exec command the ruby::bundle resource requires the command to be executed to be passed to the option parameter')
      }
    }
    'update':{
      if $option {
        validate_re(
          $option,
          ['--local', '--source='],
          'Only bundler options supported for the update command are: local and source'
        )
        $real_command = "bundle ${command}${multicore_str} ${option}"
        $real_unless  = "bundle outdated${multicore_str} ${option}"
      } else {
        $real_command = "bundle ${command}${multicore_str}"
        $real_unless  = 'bundle outdated'
      }
    }
    default: {
      fail ('Only the bundler commands install, exec, and update are supported.')
    }
  }

  exec{"ruby_bundle_${name}":
    command     => $real_command,
    creates     => $creates,
    cwd         => $cwd,
    environment => $real_environment,
    user        => $user,
    group       => $group,
    logoutput   => $logoutput,
    onlyif      => $onlyif,
    path        => $real_path,
    refresh     => $refresh,
    refreshonly => $refreshonly,
    timeout     => $timeout,
    tries       => $tries,
    try_sleep   => $try_sleep,
    unless      => $real_unless,
    require     => Package['bundler'],
  }
}
