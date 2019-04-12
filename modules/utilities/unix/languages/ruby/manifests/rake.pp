# == Define: ruby::rake
#
# This resource runs [Rake](http://docs.seattlerb.org/rake/) tasks. This resource was created to be sure that Rake tasks would only be executed once their requirements were met by the `ruby::dev` class.
#
# As running rake under bundle is a common scenario, the `bundle` parameter will automatically wrap a rake task as a `bundle exec rake` command. This ensures that the rake command passes through the sanity checking in the `ruby::rake` resource, and meets the dependency requirements needed for both rake and bundler tasks.
#
# === Parameters
#
# Most of the parameters for this resource are passed through to the underlying `exec` resource that runs the Rake task. Check the Puppetlabs documentation on the [exec resource](http://docs.puppetlabs.com/references/latest/type.html#exec) for more details. Some parameters are not available.
#
# [*task]
# (this parameter is required) This parameter is the Ruby task to be performed as a string with command line options. e.g. `db:setup`.
# [*rails_env]
# (default is `production`) This parameter is used to set the `RAILS_ENV` environment variable, the default is to set it to production. This parameter is combined with the `environment` parameter to be passed to the `environment` parameter of the underlying `exec` resource that runs the rake task.
# [*bundle]
# (default is false) If set to true, the Rake task is automatically run under a `ruby::bundler` resource.
# [*creates]
# (default is undefined) Passed through to the underlying `exec` resource that runs the rake task.
# [*cwd]
# (default is undefined) Passed through to the underlying `exec` resource that runs the rake task.
# [*environment]
# (default is undefined) This parameter is combined with the `rails_env` parameter to be passed to the `environment` parameter of the underlying `exec` resource that runs the rake task.
# [*user]
# (default is undefined) Passed through to the underlying `exec` resource that runs the rake task.
# [*group]
# (default is undefined) Passed through to the underlying `exec` resource that runs the rake task.
# [*logoutput]
# (default is undefined) Passed through to the underlying `exec` resource that runs the rake task.
# [*onlyif]
# (default is undefined) Passed through to the underlying `exec` resource that runs the rake task.
# [*path]
# (default is `['/usr/bin','/bin','/usr/sbin','/sbin']`) The rake executable has a minimum path requirement, if this parameter is left undefined, the default minimum path will be used. If a list of paths is provided, this list will be modified to be sure that it still meets the minimum path requirements for the rake executable. This is then passed to the underlying `exec` resource that runs the rake task.
# [*refresh]
# (default is undefined) Passed through to the underlying `exec` resource that runs the rake task.
# [*refreshonly]
# (default is undefined) Passed through to the underlying `exec` resource that runs the rake task.
# [*timeout]
# (default is undefined) Passed through to the underlying `exec` resource that runs the rake task.
# [*tries]
# (default is undefined) Passed through to the underlying `exec` resource that runs the rake task.
# [*try_sleep]
# (default is undefined) Passed through to the underlying `exec` resource that runs the rake task.
# [*unless]
# (default is undefined) Passed through to the underlying `exec` resource that runs the rake task.
#
# === Examples
#
# An example on setting up an application's database:
#
#   ruby::rake { 'setup_app_db':
#     task  => 'db:setup',
#     cwd   => '/path/to/app',
#   }
#
# An example on setting up an application's database, with bundler:
#
#   ruby::rake { 'setup_app_db':
#     task    => 'db:setup',
#     bundle  => true,
#     cwd     => '/path/to/app',
#   }
#
define ruby::rake
(
  $task,
  $rails_env    = undef,
  $bundle       = false,
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

  # Hmm this works on http://rubular.com/
  # validate_re($task, '^[a-z][a-z0-9]*((:[a-z][a-z0-9]*)?)*$', "The rake task '${task}' does not conform to an expected format.")

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

  $real_command = join(['rake', $task],' ')

  # wrapping rake tasks in bundler is a common practice, this makes sure
  # dependencies and requirements are met.
  if $bundle {
    ruby::bundle{"ruby_rake_${name}":
      command     => 'exec',
      option      => $real_command,
      rails_env   => $rails_env_real,
      creates     => $creates,
      cwd         => $cwd,
      environment => $environment,
      user        => $user,
      group       => $group,
      logoutput   => $logoutput,
      onlyif      => $onlyif,
      path        => $path,
      refresh     => $refresh,
      refreshonly => $refreshonly,
      timeout     => $timeout,
      tries       => $tries,
      try_sleep   => $try_sleep,
      unless      => $unless,
      require     => Package['rake'],
    }
  } else {
    exec{"ruby_rake_${name}":
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
      unless      => $unless,
      require     => Package['rake'],
    }
  }
}
