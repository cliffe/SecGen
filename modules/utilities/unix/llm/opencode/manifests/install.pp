# OpenCode, installed globally through npm, with an OpenAI-compatible provider preset for every user on the
# system. OpenCode holds the model connection and runs the agent loop; MCP servers are registered separately
# (see the rea module), which is why the config is assembled from fragments rather than written whole.
class opencode::install {
  require nodejs::install
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  $opencode_version     = $secgen_parameters['opencode_version'][0]
  $provider_sdk_version = $secgen_parameters['provider_sdk_version'][0]

  $relay_ip = $secgen_parameters['llm_relay_ip'][0]
  if $relay_ip and $relay_ip != '' {
    $relay_port = $secgen_parameters['llm_relay_port'][0]
    $llm_url    = "http://${relay_ip}:${relay_port}/api/v1"
  } else {
    $llm_url = $secgen_parameters['llm_api_url'][0]
  }
  $llm_key    = $secgen_parameters['llm_api_key'][0]
  $llm_models = $secgen_parameters['llm_models']

  $provider_dir = '/opt/opencode-providers'
  $sdk_package  = '@ai-sdk/openai-compatible'
  $fragment_dir = '/usr/local/lib/secgen-opencode'

  # nodejs sets npm's prefix to /usr/local, so the executable lands in /usr/local/bin
  exec { 'npm install opencode':
    command => "npm install -g --no-fund --no-audit opencode-ai@${opencode_version}",
    creates => '/usr/local/lib/node_modules/opencode-ai',
    timeout => 1800,
  }

  file { $provider_dir:
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  # npm otherwise walks up looking for a package.json and installs somewhere above $provider_dir
  file { "${provider_dir}/package.json":
    ensure  => file,
    content => "{ \"name\": \"secgen-opencode-providers\", \"private\": true }\n",
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => File[$provider_dir],
  }

  # The provider SDK is installed here and referenced from the config by absolute path. Left to itself OpenCode
  # fetches it from the npm registry the first time a student runs it, which fails on a VM with no outbound route.
  exec { 'npm install opencode provider sdk':
    command => "npm install --prefix ${provider_dir} --no-fund --no-audit ${sdk_package}@${provider_sdk_version}",
    creates => "${provider_dir}/node_modules/${sdk_package}",
    timeout => 1800,
    require => File["${provider_dir}/package.json"],
  }

  # Fragments merged into each user's config, in filename order. Other modules add their own here.
  file { $fragment_dir:
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  # Root-only: it holds the API key, which the merge then copies into each user's own config
  file { "${fragment_dir}/10-provider.json":
    ensure  => file,
    content => template('opencode/provider.json.erb'),
    mode    => '0600',
    owner   => 'root',
    group   => 'root',
    require => File[$fragment_dir],
  }

  file { '/usr/local/sbin/secgen-opencode-merge-config':
    ensure  => file,
    source  => 'puppet:///modules/opencode/secgen-opencode-merge-config',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    require => Exec['npm install opencode'],
  }

  exec { 'merge OpenCode config':
    command => '/usr/local/sbin/secgen-opencode-merge-config',
    unless  => '/usr/local/sbin/secgen-opencode-merge-config --check',
    require => [
      File['/usr/local/sbin/secgen-opencode-merge-config'],
      File["${fragment_dir}/10-provider.json"],
      Exec['npm install opencode provider sdk'],
    ],
  }
}
