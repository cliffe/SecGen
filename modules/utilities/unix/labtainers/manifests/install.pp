class labtainers::install{
  # $json_inputs = base64('decode', $::base64_inputs)
  # $secgen_parameters = parsejson($json_inputs)
  # $server_ip = $secgen_parameters['server_ip'][0]
  # $port = $secgen_parameters['port'][0]
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $lab = $secgen_parameters['lab'][0]
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $flags_string = $strings_to_leak.join(",")
  
  $env = "PYTHONPATH=/opt/labtainer/scripts/labtainer-student/bin/:/opt/labtainer/scripts/labtainer-instructor/bin/ LABTAINER_DIR=/opt/labtainer/"


  # these are also installed by the install script, but good to use puppet where possible
  package { ['apt-transport-https', 'ca-certificates', 'curl', 'gnupg2', 'software-properties-common', 'python3-pip', 'openssh-server', 'python3-netaddr', 'python3-parse', 'python3-dateutil', 'okular', 'gnome-terminal']:
    ensure   => 'installed',
  } ->

  file { '/opt/labtainer':
    ensure  => directory,
    recurse => true,
    source  => 'puppet:///modules/labtainers/Labtainers-master',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    ignore  => ['labs'], # Ignore the entire labs directory
  } ->

  file { '/opt/labtainer/labs':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  } ->

  file { "/opt/labtainer/labs/${lab}":
    ensure  => directory,
    recurse => true,
    source  => "puppet:///modules/labtainers/Labtainers-master/labs/${lab}",
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  } ->

  # append to /opt/labtainer/labs/${lab}/docs/read_first.txt with $strings_to_leak array joined by newlines
  file_line { 'append_read_first':
    path  => "/opt/labtainer/labs/${lab}/docs/read_first.txt",
    line  => "\nFLAG SUBMISSION\n   When you have completed the lab, ignore the labsheet submission instructions\n   instead submit the following to Hacktivity:\n   $flags_string",
    match => 'FLAG SUBMISSION',
  }

  # Set permissions to enable creation of log files etc
  # exec { 'permissions for logging':
  #   command  => "/bin/chmod a+rwt /opt/labtainer/scripts/labtainer-student/ /opt/labtainer/scripts/labtainer-instructor/ /opt/labtainer/setup_scripts/",
  #   provider => shell,
  # } ->

  # not sure why this is required in our environment, but this fixes the script on our VM builds
  # file_line { 'patch_build_image':
  #   path  => '/opt/labtainer/scripts/labtainer-student/bin/buildImage.sh',
  #   line  => '#shift 1 -- SecGen fix',
  #   match => 'shift 1',
  # } ->

  exec { 'build capinout tool':
    command  => "/bin/bash ./mkit.sh | true",
    provider => shell,
    cwd => "/opt/labtainer/tool-src/capinout"
  } ->


  # # remove docker proxy config (it's in the template, and this overrides)
  # exec { 'docker_remove_config_and_restart':
  #   command  => "mv /etc/default/docker /etc/default/docker.mv; systemctl daemon-reload; systemctl restart docker",
  #   provider => shell,
  # }


  # pull the grading image
  docker::image { "mfthomps/labtainer.grader:latest": }

  # the user of the lab must also be in the docker group

  # user { 'grader':
	#   ensure           => 'present',
  #   home             => '/home/grader',
  #   groups            => 'docker',
  #   password         => '!!',
  #   password_max_age => '99999',
  #   password_min_age => '0',
  #   shell            => '/bin/bash',
  # } ->
  # Add user account
  ::accounts::user { 'grader':
    shell      => '/bin/bash',
    groups     => ['docker'],
    password   => '!!',
    managehome => true,
  } ->

  # generate json when checking work
  file { "/opt/labtainer/scripts/labtainer-student/bin/checkwork_json":
    ensure => present,
    source => 'puppet:///modules/labtainers/labtainer.files/checkwork_json',
    mode   => '755',
    owner => 'root',
    group => 'root',
  } ->



  # Ensure the directory for the virtual environment exists
  file { '/opt/labtainer/venv':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  } ->

  exec { 'install_virtualenv':
    command => 'pip install --break-system-packages virtualenv',
    provider => shell,
  } ->
  exec { 'create_virtualenv':
    command => 'virtualenv -p `which python3` /opt/labtainer/venv/',
    provider => shell,
  } ->


  exec { 'activate_virtualenv_and_install_packages':
    command => '/bin/bash -c "source /opt/labtainer/venv/bin/activate && pip install --upgrade pip && pip install \'requests<2.29.0\' \'urllib3<2.0\' netaddr parse python-dateutil docker"',
    provider => shell,
  } ->

  file { '/opt/labtainer/logs':
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '0777',
  } ->
  file { '/opt/labtainer/logs/pull.log':
    ensure => file,
    owner => 'root',
    group => 'root',
    mode => '0777',
  } ->

  # activate and pull lab (pull_lab.py labname)
  #
  # pull_lab.py resolves its registry via registry.getBranchRegistry(). Under
  # /opt/labtainer (a plain copy, not a git checkout) and with no
  # LABTAINER_BRANCH set, that falls through to the *test* registry
  # (testregistry:5000), so `docker pull` fails and pull_lab.py swallows the
  # error (os.system ignores the exit code) - the lab image is never fetched.
  # Setting LABTAINER_BRANCH to a branch absent from config/registry.config
  # makes getBranchRegistry() return the default registry (labtainers on Docker
  # Hub), where the lab images live. pull-all.py already uses the default
  # registry, so only pull_lab.py needs this. The trailing docker-images check
  # makes the build fail loudly if the lab image is still missing, rather than
  # leaving a silently broken VM.
  exec { 'activate_virtualenv_and_pull_lab':
    command => "source /opt/labtainer/venv/bin/activate && $env /opt/labtainer/setup_scripts/pull-all.py && $env LABTAINER_BRANCH=master /opt/labtainer/setup_scripts/pull_lab.py $lab && docker images --format '{{.Repository}}' | grep -q '${lab}\\.'",
    provider => shell,
    cwd => "/opt/labtainer/setup_scripts",
    # pull-all.py fetches ~13 large base images plus the lab's images; the
    # default 300s exec timeout is far too short
    timeout => 7200,
  }
  



  # file_line { 'update_pull_all_sh':
  #   path  => '/opt/labtainer/setup_scripts/pull-all.sh',
  #   line  => '/opt/labtainer/setup_scripts/pull-all.py 2>&1 | tee /opt/labtainer/setup_scripts/logs/pull.log',
  #   match => '^./pull-all.py',
  #   notify => Exec['download labs'],  # Ensure the exec is notified to run after the change
  # }
}
