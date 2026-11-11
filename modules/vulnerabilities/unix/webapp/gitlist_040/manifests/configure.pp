class gitlist_040::configure {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  # Optional cosmetic identity of the repository, so a scenario can make the box
  # read as its own organisation's source server rather than a generic lab box.
  # All three default to the historical values, so scenarios that do not set them
  # are completely unaffected.
  #   repo_name            - the repository directory name (shown in GitList's repo
  #                          list and .git/description). Default 'secret_files'.
  #   commit_author_name   - git author/committer name on every commit (shown in
  #                          GitList's commit view and in `git log`). Default 'gitlist'.
  #   commit_author_email  - git author/committer email. Default 'git@list.com'.
  $repo_name_raw = $secgen_parameters['repo_name']
  $have_repo_name = ($repo_name_raw != undef) and ($repo_name_raw[0] != undef) and ($repo_name_raw[0] != '')
  $repo_name = $have_repo_name ? { true => $repo_name_raw[0], default => 'secret_files' }
  $leaked_files_path = "/home/git/repositories/${repo_name}"

  $author_name_raw = $secgen_parameters['commit_author_name']
  $have_author_name = ($author_name_raw != undef) and ($author_name_raw[0] != undef) and ($author_name_raw[0] != '')
  $commit_author_name = $have_author_name ? { true => $author_name_raw[0], default => 'gitlist' }

  $author_email_raw = $secgen_parameters['commit_author_email']
  $have_author_email = ($author_email_raw != undef) and ($author_email_raw[0] != undef) and ($author_email_raw[0] != '')
  $commit_author_email = $have_author_email ? { true => $author_email_raw[0], default => 'git@list.com' }

  $images_to_leak = $secgen_parameters['images_to_leak']

  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_pre_leak = $secgen_parameters['strings_to_pre_leak']
  $pre_leaked_filenames = $secgen_parameters['pre_leaked_filenames']

  # Optional: a secret committed into the repo then removed in a later commit, so
  # it is absent from the working tree / HEAD (and GitList's file browser) but
  # recoverable from history. Empty unless a scenario opts in -> no extra commits.
  $strings_to_leak_in_history   = $secgen_parameters['strings_to_leak_in_history']
  $history_leaked_filenames_raw = $secgen_parameters['history_leaked_filenames']
  $history_commit_message_raw   = $secgen_parameters['history_commit_message']
  $history_removal_message_raw  = $secgen_parameters['history_removal_commit_message']

  # when there are multiple strings to leak:
  #   leak the first one as a flag, requiring exploitation to access;
  #   leak the subsequent ones publically through the website;

  if $strings_to_leak.length == 0 {
    warning('No strings_to_leak provided!')
  }

  # A blank first element means "do not leak a loose file". Only a scenario that
  # explicitly passes an empty value hits this; the default message_generator and
  # every existing caller supply a non-blank value, so their behaviour is unchanged.
  $has_loose_leak = ($strings_to_leak != undef) and ($strings_to_leak[0] != undef) and ($strings_to_leak[0] != '')

  # Decide whether a secret should be buried in deleted history.
  $do_history_leak = ($strings_to_leak_in_history != undef) and ($strings_to_leak_in_history[0] != undef) and ($strings_to_leak_in_history[0] != '')

  $git_args = "-c user.name=\"${commit_author_name}\" -c user.email=\"${commit_author_email}\""

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  # Create /home/git/repositories
  file { ['/home/git', '/home/git/repositories']:
    ensure => directory,
    owner  => 'www-data',
  } ->

  file { $leaked_files_path:
    ensure => directory,
    owner => 'www-data',
    mode => '0700'
  } ->

  exec { 'create-repo-file_leak':
    cwd     => $leaked_files_path,
    command => "sudo -u www-data git init",
  } ->

  file { "$leaked_files_path/.git/description":
    content => $repo_name,
    owner => 'www-data'
  }

  # Guarantee the repository holds searchable text. GitList's search runs
  # `git grep -I --line-number <query> c` (exploit/multi/http/gitlist_arg_injection
  # posts its injection to .../tree/c/search, so 'c' becomes the grep pattern), and
  # the injected --open-files-in-pager payload only executes when git grep finds a
  # tracked file whose content matches that pattern. The randomly generated leak
  # files are sometimes an ASCII-art image with no 'c', which leaves the repo
  # unsearchable and the exploit inert; this committed README always matches.
  # Skipped when the scenario leaks its own README.md into the repo (m08 does):
  # leak_file would otherwise append the scenario's text to this one.
  $pre_names = $pre_leaked_filenames ? { undef => [], default => $pre_leaked_filenames }
  unless 'README.md' in $pre_names {
    file { "${leaked_files_path}/README.md":
      ensure  => file,
      owner   => 'www-data',
      mode    => '0640',
      content => "Internal service repository.\nContains source code and configuration notes.\n",
      require => Exec['create-repo-file_leak'],
      before  => Exec['initial_commit_leaked_files_repo'],
    }
  }

  if $has_loose_leak {
    ::secgen_functions::leak_files { 'gitlist_040-flag-leak':
      storage_directory => '/home/git',
      leaked_filenames  => $leaked_filenames,
      strings_to_leak   => $strings_to_leak,
      owner             => 'www-data',
      mode              => '0750',
      leaked_from       => 'gitlist_040',
      before            => Exec['initial_commit_leaked_files_repo']
    }
  }

  ::secgen_functions::leak_files { 'gitlist_040-file-leak':
    storage_directory => $leaked_files_path,
    leaked_filenames  => $pre_leaked_filenames,
    strings_to_leak   => $strings_to_pre_leak,
    images_to_leak    => $images_to_leak,
    owner             => 'www-data',
    mode              => '0750',
    leaked_from       => 'gitlist_040',
    before            => Exec['initial_commit_leaked_files_repo']
  }

  exec { 'initial_commit_leaked_files_repo':
    cwd     => $leaked_files_path,
    command => "sudo -u www-data git $git_args add *; sudo -u www-data git $git_args commit -a -m 'initial commit'",
  }

  # Bury the secret in deleted history: commit it, then remove it in a later
  # commit. GitList serves HEAD, so the removed file is not browsable, but it
  # remains in the repo's object store (git log/show).
  if $do_history_leak {
    # Fall back to a sane filename if the scenario supplied strings but no name.
    if ($history_leaked_filenames_raw != undef) and ($history_leaked_filenames_raw[0] != undef) and ($history_leaked_filenames_raw[0] != '') {
      $history_leaked_filenames = $history_leaked_filenames_raw
    } else {
      $history_leaked_filenames = ['secret']
    }
    $history_rm_targets = join($history_leaked_filenames, ' ')

    # Commit messages: scenario-supplied, or a generic default. Passed via -F so
    # apostrophes / shell metacharacters in the message cannot break the exec.
    $have_add_msg = ($history_commit_message_raw != undef) and ($history_commit_message_raw[0] != undef) and ($history_commit_message_raw[0] != '')
    $history_add_msg = $have_add_msg ? { true => $history_commit_message_raw[0], default => 'work in progress' }
    $have_rm_msg = ($history_removal_message_raw != undef) and ($history_removal_message_raw[0] != undef) and ($history_removal_message_raw[0] != '')
    $history_rm_msg = $have_rm_msg ? { true => $history_removal_message_raw[0], default => 'cleanup' }

    file { '/home/git/.gl_history_add_msg':
      ensure  => file,
      content => "$history_add_msg\n",
      owner   => 'www-data',
      mode    => '0600',
      require => File['/home/git'],
    }

    file { '/home/git/.gl_history_rm_msg':
      ensure  => file,
      content => "$history_rm_msg\n",
      owner   => 'www-data',
      mode    => '0600',
      require => File['/home/git'],
    }

    ::secgen_functions::leak_files { 'gitlist_040-history-leak':
      storage_directory => $leaked_files_path,
      leaked_filenames  => $history_leaked_filenames,
      strings_to_leak   => $strings_to_leak_in_history,
      owner             => 'www-data',
      mode              => '0750',
      leaked_from       => 'gitlist_040-history',
      require           => Exec['initial_commit_leaked_files_repo'],
      before            => Exec['history_add_commit_leaked_files_repo'],
    }

    exec { 'history_add_commit_leaked_files_repo':
      cwd     => $leaked_files_path,
      command => "sudo -u www-data git $git_args add -A; sudo -u www-data git $git_args commit -F /home/git/.gl_history_add_msg",
      require => [Exec['initial_commit_leaked_files_repo'], File['/home/git/.gl_history_add_msg']],
    } ->

    exec { 'history_remove_commit_leaked_files_repo':
      cwd     => $leaked_files_path,
      command => "sudo -u www-data git $git_args rm $history_rm_targets; sudo -u www-data git $git_args commit -F /home/git/.gl_history_rm_msg",
      require => File['/home/git/.gl_history_rm_msg'],
    }
  }
}
