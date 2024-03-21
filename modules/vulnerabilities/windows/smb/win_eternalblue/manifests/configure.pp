# Class: win_eternalblue::configure
# Configuration for eternalblue
#
class win_eternalblue::configure {
  file { 'c:\Share':
    ensure => directory,
  }
  # Here we enable a share on the created directory - this gets round the "public" adapter type
  # Note: It cannot be "turned off" in a traditional sense by deleting the share
  # The inbound firewall rules, for public and private adaptors, need enabling/disabling to stop exploitation
  -> exec { 'enable-sharing':
    command => 'c:\Windows\System32\cmd.exe /c net share Share="c:\Share" /grant:everyone,FULL',
  }

  $user = 'shunoban' ##$secgen_parameters['leaked_username'][0]
  $leaked_filenames = ['flagtest'] ##$secgen_parameters['leaked_filenames']
  $strings_to_leak = ['this is a list of strings that are secrets / flags','another secret'] ##$secgen_parameters['strings_to_leak']

  ::secgen_functions::leak_files { 'easychat-flag-leak':
    storage_directory => "C:\Users\\${user}\\",
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => $user,
    leaked_from       => 'easychat_bo',
  }
}
