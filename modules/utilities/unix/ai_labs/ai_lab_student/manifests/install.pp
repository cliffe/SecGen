# Installs one lab's notebook and data for each account. Labs that mustn't give
# students a labelled dataset get an unlabelled image pool, built from an archive
# that is deleted straight afterwards.
class ai_lab_student::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $lab = $secgen_parameters['lab'][0]
  $pool_size = $secgen_parameters['pool_size'][0]
  $accounts = $secgen_parameters['accounts'] ? {
    undef   => [],
    default => $secgen_parameters['accounts'],
  }
  $python = '/opt/python_ml_env/bin/python'
  $mnist = '/opt/ai_lab/.mnist.npz'
  $path = ['/usr/bin', '/bin']

  file { '/opt/ai_lab':
    ensure => directory,
    mode   => '0755',
  }

  file { '/opt/ai_lab/predict_student.py':
    ensure  => file,
    source  => 'puppet:///modules/ai_lab_student/predict_student.py',
    mode    => '0644',
    require => File['/opt/ai_lab'],
  }

  file { '/opt/ai_lab/make_pool.py':
    ensure  => file,
    source  => 'puppet:///modules/ai_lab_student/make_pool.py',
    mode    => '0644',
    require => File['/opt/ai_lab'],
  }

  $data_file = $lab ? {
    'model_stealing' => 'query_pool.npy',
    default          => 'train_data.npz',
  }

  if $lab == 'model_stealing' or $lab == 'backdoor' {
    exec { 'ai_lab_student make pool':
      command  => "curl -fsSL --retry 3 -o ${mnist} https://storage.googleapis.com/tensorflow/tf-keras-datasets/mnist.npz && ${python} -I /opt/ai_lab/make_pool.py ${lab} ${mnist} /opt/ai_lab/${data_file} ${pool_size}; rc=\$?; rm -f ${mnist}; exit \$rc",
      creates  => "/opt/ai_lab/${data_file}",
      provider => shell,
      path     => $path,
      timeout  => 600,
      require  => File['/opt/ai_lab/make_pool.py'],
    }
  }

  $accounts.each |$raw_account| {
    if $raw_account != '' {
      $account  = parsejson($raw_account)
      $username = $account['username']
      $home     = "/home/${username}"

      file { "${home}/lab":
        ensure  => directory,
        recurse => true,
        source  => "puppet:///modules/ai_lab_student/${lab}",
        owner   => $username,
        group   => $username,
      }

      if $lab == 'model_stealing' or $lab == 'backdoor' {
        file { "${home}/lab/${data_file}":
          ensure  => file,
          source  => "/opt/ai_lab/${data_file}",
          owner   => $username,
          group   => $username,
          mode    => '0644',
          require => [Exec['ai_lab_student make pool'], File["${home}/lab"]],
        }
      }

      file { "${home}/Desktop":
        ensure => directory,
        owner  => $username,
        group  => $username,
      }

      file { "${home}/Desktop/jupyterlab.desktop":
        ensure  => file,
        owner   => $username,
        group   => $username,
        mode    => '0755',
        content => "[Desktop Entry]\nType=Application\nName=JupyterLab\nComment=Open the lab notebook\nExec=sh -c 'cd \"\$HOME/lab\" && /opt/python_ml_env/bin/jupyter lab'\nIcon=applications-science\nTerminal=true\n",
      }
    }
  }
}
