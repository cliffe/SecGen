# Clones a Git repository at a fixed commit into /opt/<repo_name> and gives each account its own copy in
# ~/<repo_name>, the Keras MNIST archive in ~/.keras/datasets, and a JupyterLab launcher on the desktop.
# Used from other modules' runs, after python_ml_env::install has run on the system.
define python_ml_env::notebook_repo (
  $repo_url,
  $commit,
  $accounts  = [],
  $repo_name = $title,
) {
  $src  = "/opt/${repo_name}"
  $venv = '/opt/python_ml_env'
  $path = ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']

  # A shallow fetch of one commit (no history); cloned to a .partial directory first so an interrupted fetch
  # can't leave a directory that `creates` would treat as done.
  exec { "notebook_repo clone ${repo_name}":
    command  => "rm -rf ${src}.partial && git init -q ${src}.partial && git -C ${src}.partial fetch -q --depth 1 ${repo_url} ${commit} && git -C ${src}.partial checkout -q FETCH_HEAD && mv ${src}.partial ${src}",
    creates  => $src,
    provider => shell,
    path     => $path,
    timeout  => 0,
  }

  $accounts.each |$raw_account| {
    if $raw_account != '' {
      $account  = parsejson($raw_account)
      $username = $account['username']
      $home     = "/home/${username}"

      exec { "notebook_repo copy ${repo_name} for ${username}":
        command  => "cp -a ${src} ${home}/${repo_name} && chown -R ${username}:${username} ${home}/${repo_name}",
        creates  => "${home}/${repo_name}",
        provider => shell,
        path     => $path,
        require  => Exec["notebook_repo clone ${repo_name}"],
      }

      ensure_resource('file', ["${home}/.keras", "${home}/.keras/datasets", "${home}/Desktop"], {
        ensure => directory,
        owner  => $username,
        group  => $username,
      })

      ensure_resource('file', "${home}/.keras/datasets/mnist.npz", {
        ensure => file,
        source => "${venv}/datasets/mnist.npz",
        owner  => $username,
        group  => $username,
        mode   => '0644',
      })

      ensure_resource('file', "${home}/Desktop/jupyterlab.desktop", {
        ensure  => file,
        owner   => $username,
        group   => $username,
        mode    => '0755',
        content => "[Desktop Entry]\nType=Application\nName=JupyterLab\nComment=Notebook server for the lab repositories in your home directory\nExec=sh -c 'cd \"\$HOME\" && ${venv}/bin/jupyter lab'\nIcon=applications-science\nTerminal=true\n",
      })
    }
  }
}
