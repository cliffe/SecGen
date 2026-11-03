class labtainers::config{
  require labtainers::install

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $lab = $secgen_parameters['lab'][0]
  $accounts = $secgen_parameters['accounts']

  $env = "PYTHONPATH=/opt/labtainer/scripts/labtainer-student/bin/:/opt/labtainer/scripts/labtainer-instructor/bin/ LABTAINER_DIR=/opt/labtainer/"

  # Set permissions to enable creation of log files etc
  file { ['/opt/labtainer/scripts/labtainer-instructor/grader.log',
          '/opt/labtainer/scripts/labtainer-instructor/saki.log',
          '/opt/labtainer/scripts/labtainer-student/labtainer.log',
          '/opt/labtainer/scripts/labtainer-student/grader.log']:
    ensure  => 'present',
    content => "SecGen was here\n",
    mode    => '0666',
  } ->
  file { '/opt/labtainer/scripts/labtainer-student/.tmp':
    ensure => directory,
    mode    => '0777',
  }

  # Ensure the logs directory exists
  file { '/opt/labtainer/setup_scripts/logs':
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  # Set.up labtainers for each user account
  unless $accounts == undef {
    $accounts.each |$raw_account| {
      $account = parsejson($raw_account)
      $username = $account['username']
      # set home directory
      if $username == 'root' {
        $home_dir = "/root"
      } else {
        $home_dir = "/home/$username"
      }
      $labtainer_dir = "$home_dir/labtainer"

      file { ["$home_dir/",
        "$labtainer_dir"]:
        ensure  => directory,
        owner   => $username,
        group   => $username,
      } ->

      file { "$labtainer_dir/labtainer-student":
        ensure => 'link',
        target => '/opt/labtainer/scripts/labtainer-student',
      } ->

      file_line { "patch_path_labtainers_${username}":
        path  => "$home_dir/.profile",
        line  => 'export PATH=/opt/labtainer/scripts/labtainer-student/bin:/opt/labtainer/scripts/labtainer-instructor/bin:/opt/labtainer/scripts/labtainer-student/lab-bin/:/opt/labtainer/setup_scripts/trunk/scripts/designer/bin:/opt/labflags/:$PATH',
      } ->
      file_line { "patch_path_labtainers_dir_${username}":
        path  => "$home_dir/.bashrc",
        line  => 'export LABTAINER_DIR="/opt/labtainer/"',
      } ->

      # autostart script
      file { ["$home_dir/.config/", "$home_dir/.config/autostart/"]:
        ensure => directory,
        owner  => $username,
        group  => $username,
      } ->

      file { "$home_dir/.config/autostart/auto_start_lab.desktop":
        ensure => file,
        content => template('labtainers/auto_start_lab.desktop.erb'),
        owner  => $username,
        group  => $username,
      } ->
      #ensure directory (share and applications)
      file { ["$home_dir/.local/", "$home_dir/.local/share/", "$home_dir/.local/share/applications/"]:
        ensure => directory,
        owner  => $username,
        group  => $username,
      } ->
      file { "$home_dir/.local/share/applications/start_lab.desktop":
        ensure => file,
        content => template('labtainers/auto_start_lab.desktop.erb'),
        owner  => $username,
        group  => $username,
      } ->
      # # make KDE favorite
      # exec { 'make favorite':
      #   command => "sudo -u $username bash -c 'dbus-send --type=method_call --dest=org.kde.ActivityManager /ActivityManager/Resources/Linking org.kde.ActivityManager.ResourcesLinking.LinkResourceToActivity string:org.kde.plasma.favorites.applications string:applications:\"start_lab.desktop\" string::any'",
      #   provider => shell,
      # } ->

      exec { "activate_virtualenv_and_start_lab_${username}":
        command  => "sudo -u $username bash -c 'source ~/.profile; source /opt/labtainer/venv/bin/activate; echo -e \"email@addre.ss\\n\\n\" | $env /opt/labtainer/scripts/labtainer-student/bin/labtainer $lab -q'",
        cwd => "/opt/labtainer/scripts/labtainer-student/",
        provider => shell,
        # starting the lab builds/starts containers; allow more than the default 300s
        timeout => 3600,
      } 
      # ->

      # # add a call to the start.py script
      # exec { 'start_lab':
      #   command => "sudo -u $username bash -c 'cd /opt/labtainer/scripts/labtainer-student/; source /opt/labtainer/venv/bin/activate; echo \"Running lab $lab\"; echo -e '/n/n/n'| PYTHONPATH=/opt/labtainer/scripts/labtainer-student/bin/:/opt/labtainer/scripts/labtainer-instructor/bin/ LABTAINER_DIR=/opt/labtainer/ labtainer $lab; bash'",
      #   provider => shell,
      # }
    }
  }


  file { 'patch_grader_path_labtainers':
    path  => "/home/grader/.profile",
    content  => 'export PATH=/opt/labtainer/scripts/labtainer-student/bin:/opt/labtainer/scripts/labtainer-instructor/bin:/opt/labtainer/scripts/labtainer-student/lab-bin/:/opt/labtainer/setup_scripts/trunk/scripts/designer/bin:/opt/labflags/:$PATH
    export LABTAINER_DIR=/opt/labtainer/',
    owner  => 'grader',
    group  => 'grader',
  }

  # exec { 'permissions for logging':
  #   command  => "/bin/chmod a+rwt /opt/labtainer/scripts/labtainer-student/ /opt/labtainer/scripts/labtainer-instructor/ /opt/labtainer/setup_scripts/",
  #   provider => shell,
  # } ->
}
