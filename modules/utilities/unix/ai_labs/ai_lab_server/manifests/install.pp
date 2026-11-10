# Installs the lab code, writes the per-build parameters and trains the target model.
class ai_lab_server::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $lab_params = $secgen_parameters['lab_params'][0]
  $python = '/opt/python_ml_env/bin/python'

  user { 'ai_lab':
    ensure => present,
    system => true,
    shell  => '/usr/sbin/nologin',
  }

  file { '/opt/ai_lab':
    ensure => directory,
    mode   => '0755',
  }

  file { '/opt/ai_lab/code':
    ensure  => directory,
    recurse => true,
    purge   => true,
    source  => 'puppet:///modules/ai_lab_server/ai_lab',
    mode    => '0644',
    require => File['/opt/ai_lab'],
  }

  file { ['/opt/ai_lab/private', '/opt/ai_lab/model']:
    ensure  => directory,
    owner   => 'root',
    group   => 'ai_lab',
    require => [File['/opt/ai_lab'], User['ai_lab']],
  }

  File['/opt/ai_lab/private'] { mode => '0700' }
  File['/opt/ai_lab/model'] { mode => '0750' }

  file { '/var/lib/ai_lab':
    ensure  => directory,
    owner   => 'ai_lab',
    group   => 'ai_lab',
    mode    => '0750',
    require => User['ai_lab'],
  }

  file { '/opt/ai_lab/private/params.json':
    ensure  => file,
    content => $lab_params,
    mode    => '0600',
    require => File['/opt/ai_lab/private'],
  }

  # Slow: trains on the CPU at build time, so every build's answers differ.
  exec { 'ai_lab_server train target':
    command   => "${python} -I /opt/ai_lab/code/train.py",
    creates   => '/opt/ai_lab/model/public.json',
    path      => ['/usr/bin', '/bin'],
    timeout   => 0,
    logoutput => true,
    require   => [File['/opt/ai_lab/code'], File['/opt/ai_lab/private/params.json'], File['/opt/ai_lab/model']],
  }
}
