$secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
$images = $secgen_params['images']

# install
# include 'docker'

# TODO: configure proxy via secgen argument?
class { 'docker':
  proxy => "http://172.22.0.51:3128",
}


# remove proxy config (it's in the template, and this overrides)
# file_line { 'remove_docker_proxy1':
#   ensure            => absent,
#   path              => '/etc/default/docker',
#   line              => 'HTTP_PROXY=""',
# } ->
# file_line { 'remove_docker_proxy2':
#   ensure            => absent,
#   path              => '/etc/default/docker',
#   line              => 'http_proxy=""',
# } ->
# file_line { 'remove_docker_proxy3':
#   ensure            => absent,
#   path              => '/etc/default/docker',
#   line              => 'https_proxy=""',
# } ->
# file_line { 'remove_docker_proxy4':
#   ensure            => absent,
#   path              => '/etc/default/docker',
#   line              => 'HTTPS_PROXY=""',
# } ->
# file_line { 'remove_docker_proxy_settings':
#   ensure => absent,
#   path => '/etc/default/docker',
#   match => '^HTTP*_PROXY=*',
#   match_for_absence => true,
#   multiple => true,
#   notify  => Service['docker'],  # reload docker once changed
# }
#
# # remove proxy config (it's in the template, and this overrides)
# exec { 'docker_remove_config_and_restart':
#   command  => "mv /etc/default/docker /etc/default/docker.mv; systemctl daemon-reload; systemctl restart docker",
#   provider => shell,
# }

# remove proxy config (it's in the template, and this overrides)
# exec { 'remove_docker_proxy_conf':
#   command => 'sudo rm /etc/systemd/system/docker.service.d/*proxy.conf',
#   path    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
#   onlyif  => 'test -d /etc/systemd/system/docker.service.d && ls /etc/systemd/system/docker.service.d/*proxy.conf',
# }

# download (pull) a set of images
$images.each |$image| {
  docker::image { "$image": }
}
