# Runs the target model's API as the unprivileged ai_lab user.
class ai_lab_server::service {
  require ai_lab_server::install

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $params = parsejson($secgen_parameters['lab_params'][0])

  if $params['api'] {
    file { '/etc/systemd/system/ai_lab_api.service':
      ensure  => file,
      mode    => '0644',
      content => "[Unit]\nDescription=AI lab target model API\nAfter=network.target\n\n[Service]\nUser=ai_lab\nWorkingDirectory=/opt/ai_lab/code\nExecStart=/opt/python_ml_env/bin/gunicorn --workers 1 --timeout 120 --bind 0.0.0.0:5000 api:app\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target\n",
    }

    exec { 'ai_lab_server daemon-reload':
      command     => '/bin/systemctl daemon-reload',
      refreshonly => true,
      subscribe   => File['/etc/systemd/system/ai_lab_api.service'],
    }

    service { 'ai_lab_api':
      ensure  => running,
      enable  => true,
      require => [Exec['ai_lab_server daemon-reload'], File['/etc/systemd/system/ai_lab_api.service']],
    }
  }
}
