# Python venv with the ML stack and JupyterLab, activated in interactive bash shells, plus the Keras MNIST archive.
class python_ml_env::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $download_mnist = str2bool($secgen_parameters['download_mnist'][0])
  $venv = '/opt/python_ml_env'
  Exec { path => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'] }

  ensure_packages(['python3-venv', 'git', 'curl'])

  exec { 'python_ml_env create venv':
    command => "python3 -m venv ${venv}",
    creates => "${venv}/bin/python",
    require => Package['python3-venv'],
  }

  file { "${venv}/requirements.txt":
    ensure  => file,
    source  => 'puppet:///modules/python_ml_env/requirements.txt',
    require => Exec['python_ml_env create venv'],
  }

  # TensorFlow and its dependencies are about 2 GB of wheels: no timeout, and no pip cache left on disk.
  exec { 'python_ml_env pip install':
    command   => "${venv}/bin/pip install --no-cache-dir --upgrade pip && ${venv}/bin/pip install --no-cache-dir -r ${venv}/requirements.txt",
    unless    => "${venv}/bin/python -c 'import tensorflow, sklearn, imblearn, flask, jupyterlab'",
    provider  => shell,
    timeout   => 0,
    logoutput => true,
    require   => File["${venv}/requirements.txt"],
  }

  file { '/usr/local/bin/jupyter':
    ensure  => link,
    target  => "${venv}/bin/jupyter",
    require => Exec['python_ml_env pip install'],
  }

  # Debian reads /etc/bash.bashrc for every interactive bash shell, so `python` and `pip` are the venv's in any terminal.
  file_line { 'python_ml_env activate in bash.bashrc':
    path    => '/etc/bash.bashrc',
    line    => "[ -f ${venv}/bin/activate ] && . ${venv}/bin/activate",
    require => Exec['python_ml_env pip install'],
  }

  if $download_mnist {
    # keras.datasets.mnist.load_data() downloads this on first use; notebook_repo copies it into each account's
    # ~/.keras/datasets so it works without internet access.
    file { "${venv}/datasets":
      ensure  => directory,
      require => Exec['python_ml_env create venv'],
    }

    exec { 'python_ml_env download mnist':
      command => "curl -fsSL --retry 3 -o ${venv}/datasets/mnist.npz.partial https://storage.googleapis.com/tensorflow/tf-keras-datasets/mnist.npz && mv ${venv}/datasets/mnist.npz.partial ${venv}/datasets/mnist.npz",
      creates => "${venv}/datasets/mnist.npz",
      provider => shell,
      timeout => 600,
      require => [File["${venv}/datasets"], Package['curl']],
    }
  }
}
