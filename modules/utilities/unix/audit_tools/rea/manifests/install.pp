# REA registered as an MCP tool server for OpenCode, driving the ghidra module's installation headless.
# opencode::install is deliberately not required here: a module's manifests run as their own catalog with their
# own inputs, so evaluating that class from this run would feed it REA's inputs. The two meet through the
# fragment directory the opencode module reads instead.
class rea::install {
  require ghidra::install
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  if $operatingsystem != 'Kali' {
    fail('rea: needs the Kali (Ghidra 12) install of the ghidra module')
  }

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  $rea_version               = $secgen_parameters['rea_version'][0]
  $ghidra_startup_timeout_ms = $secgen_parameters['ghidra_startup_timeout_ms'][0]
  $mcp_startup_timeout_ms    = $secgen_parameters['mcp_startup_timeout_ms'][0]
  $mcp_execution_timeout_ms  = $secgen_parameters['mcp_execution_timeout_ms'][0]
  $java_home                 = $secgen_parameters['java_home'][0]

  $ghidra_dir = $ghidra::install::ghidra_dir
  # Read by the opencode module's merge tool, which assembles each user's config from these fragments
  $fragment_dir = '/usr/local/lib/secgen-opencode'
  $merge_tool   = '/usr/local/sbin/secgen-opencode-merge-config'
  $rea_entry    = '/usr/local/lib/node_modules/rea-agents/scripts/rea.mjs'

  # REA's process supervisor looks for a procps-compatible ps on PATH before it will launch Ghidra. Without one
  # the provider reports itself unavailable instead of naming the cause.
  ensure_packages(['procps'])

  # nodejs sets npm's prefix to /usr/local, so the executable lands in /usr/local/bin
  exec { 'npm install rea-agents':
    command => "npm install -g --no-fund --no-audit rea-agents@${rea_version}",
    creates => '/usr/local/lib/node_modules/rea-agents',
    timeout => 1800,
  }

  # The registration launches the entry script by absolute path, so stop the build here if the package layout
  # has moved rather than leaving a server that fails to start
  exec { 'confirm the REA entry script is where the registration expects':
    command  => "echo 'rea: ${rea_entry} is missing; the rea-agents package layout has changed' >&2; exit 1",
    unless   => "test -f ${rea_entry}",
    provider => shell,
    require  => Exec['npm install rea-agents'],
  }

  # A student running rea on the command line needs these in their shell. OpenCode launches the MCP server
  # without a login shell, so that copy gets them from its own environment block in the fragment below.
  file { '/etc/profile.d/rea.sh':
    ensure  => file,
    content => template('rea/rea.sh.erb'),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }

  # Declared here too so this catalog stands on its own; the opencode module creates it as well
  ensure_resource('file', $fragment_dir, {
    'ensure' => 'directory',
    'mode'   => '0755',
    'owner'  => 'root',
    'group'  => 'root',
  })

  file { "${fragment_dir}/20-rea-mcp.json":
    ensure  => file,
    content => template('rea/rea-mcp.json.erb'),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => [
      File[$fragment_dir],
      Exec['confirm the REA entry script is where the registration expects'],
    ],
  }

  exec { 'register REA with OpenCode':
    command => $merge_tool,
    unless  => "${merge_tool} --check",
    require => File["${fragment_dir}/20-rea-mcp.json"],
  }

  # Fails the build rather than handing over a lab whose agent silently has no decompiler. Checks the Ghidra
  # version, its headless launcher, and the JDK that installation declares.
  $base_env = [
    'HOME=/root',
    "GHIDRA_INSTALL_DIR=${ghidra_dir}",
    "REA_GHIDRA_STARTUP_TIMEOUT_MS=${ghidra_startup_timeout_ms}",
  ]
  if $java_home and $java_home != '' {
    $doctor_env = concat($base_env, ["JAVA_HOME=${java_home}"])
  } else {
    $doctor_env = $base_env
  }

  exec { 'verify the REA Ghidra provider':
    command     => 'rea doctor --provider ghidra --json',
    environment => $doctor_env,
    logoutput   => true,
    timeout     => 900,
    require     => [Exec['npm install rea-agents'], Package['procps']],
  }
}
