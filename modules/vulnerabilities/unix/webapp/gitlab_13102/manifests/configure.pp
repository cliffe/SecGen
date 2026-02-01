class gitlab_13102::configure {

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  # First leaked string is the gitlab root password
  $strings_to_leak     = $secgen_parameters['strings_to_leak']
  $strings_to_pre_leak = $secgen_parameters['strings_to_pre_leak']
  $difficulty          = $secgen_parameters['difficulty']
  $leaked_filenames    = $secgen_parameters['leaked_filenames']

  # Could amend in future to take port as parameter but threw error 502 in testing so leaving as default (80) for now

  Exec { path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'] }

  exec { 'set_gitlab_password':
    command => "echo \"gitlab_rails['initial_root_password'] = '${strings_to_leak[0]}'\" >> /etc/gitlab/gitlab.rb",
  }
  ->
  exec { 'set_gitlab_store_password':
    command => "echo \"gitlab_rails['store_initial_root_password'] = true\" >> /etc/gitlab/gitlab.rb",
  }
  ->
  exec { 'disable_monitoring': # Avoids race condition where monitoring services don't start before gitlab-ctl reconfigure completes
    command => "echo \"prometheus_monitoring['enable'] = false\" >> /etc/gitlab/gitlab.rb && echo \"alertmanager['enable'] = false\" >> /etc/gitlab/gitlab.rb && echo \"grafana['enable'] = false\" >> /etc/gitlab/gitlab.rb",
  }
  ->
  exec { 'reconfigure_gitlab':
    command => '/usr/bin/gitlab-ctl reconfigure > /dev/null 2>&1', # Prevents output flooding the console
    require => Exec['install_gitlab'],
    timeout => 1800,
    tries     => 3,
    try_sleep => 30,
  }

  # Leak credentials via git user's home directory
  exec { 'create_git_home':
    command => 'mkdir -p /home/git',
    creates => '/home/git',
  }
  ->
  exec { 'set_git_home_ownership':
    command => 'chown git:git /home/git',
    require => Exec['create_git_home'],
  }
  ->
  # Pre leak to robots.txt
  file_line { 'pre-leak-robots-txt':
    path => '/opt/gitlab/embedded/service/gitlab-rails/public/robots.txt',
    line => "# ${strings_to_pre_leak[0]}",
  }

  # Leak sensitive info via git repo
  file { '/home/git/.credentials':
    ensure  => file,
    content => "root:${strings_to_leak[0]}",
    owner   => 'git',
    group   => 'git',
    mode    => '0600',
    require => Exec['set_git_home_ownership'],
  }
  
  if $difficulty[0] == 'hard' {
    exec { 'create_project_dir':
      command => 'mkdir -p /tmp/dev-notes',
      creates => '/tmp/dev-notes',
      require => Exec['reconfigure_gitlab'],
    }
    ->
    exec { 'init_project':
      command => 'git init',
      cwd     => '/tmp/dev-notes',
      creates => '/tmp/dev-notes/.git',
    }
    ->
    exec { 'git_config_email':
      command => 'git config user.email "root@example.com"',
      cwd     => '/tmp/dev-notes',
    }
    ->
    # Could be amended in future to use organisation information for realistic scenario
    exec { 'git_config_name':
      command => 'git config user.name "Developer J"',
      cwd     => '/tmp/dev-notes',
    }
    ->
    exec { 'create_env_file':
      command => "echo -e 'DB_HOST=localhost\\nDB_PORT=5432\\nDB_USER=root\\nDB_PASSWORD=${strings_to_leak[1]}\\nAPI_KEY=abc123xyz' > .env",
      cwd     => '/tmp/dev-notes',
    }
    ->
    exec { 'create_python_script':
      command => "echo -e '#!/usr/bin/env python3\\nimport os\\nfrom dotenv import load_dotenv\\n\\nload_dotenv()\\n\\ndb_host = os.getenv(\"DB_HOST\")\\ndb_user = os.getenv(\"DB_USER\")\\ndb_password = os.getenv(\"DB_PASSWORD\")\\n\\nprint(f\"Connecting to {db_host} as {db_user}\")' > app.py",
      cwd     => '/tmp/dev-notes',
    }
    ->
    exec { 'git_add_important':
      command => 'git add .env app.py',
      cwd     => '/tmp/dev-notes',
    }
    ->
    exec { 'git_commit_initial':
      command => 'git commit -m "Initial commit"',
      cwd     => '/tmp/dev-notes',
    }
    ->
    exec { 'remove_env_file':
      command => 'git rm .env',
      cwd     => '/tmp/dev-notes',
    }
    ->
    exec { 'create_gitignore':
      command => 'echo ".env" > .gitignore',
      cwd     => '/tmp/dev-notes',
    }
    ->
    exec { 'git_add_gitignore':
      command => 'git add .gitignore',
      cwd     => '/tmp/dev-notes',
    }
    ->
    exec { 'git_commit_update':
      command => 'git commit -m "Removed .env file and added to .gitignore"',
      cwd     => '/tmp/dev-notes',
    }
    ->
    exec { 'git_add_remote':
      command => "git remote add origin http://root:${strings_to_leak[0]}@localhost/root/dev-notes.git",
      cwd     => '/tmp/dev-notes',
    }
    ->
    exec { 'git_push_master':
      command => 'git push -u origin master',
      cwd     => '/tmp/dev-notes',
    }
  } else {
    file { "/home/git/${leaked_filenames[0]}":
      ensure  => file,
      content => "${strings_to_leak[1]}",
      owner   => 'git',
      group   => 'git',
      mode    => '0600',
      require => Exec['set_git_home_ownership'],
    }
  }
}
