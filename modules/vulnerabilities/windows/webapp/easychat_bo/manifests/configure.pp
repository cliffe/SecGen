# Class: easychat_bo::configure
# Flag behaviour for easychat
# - Flag for user dir
# - Flag for leaking user password
class easychat_bo::configure {
  $user = 'shunoban' ##$secgen_parameters['leaked_username'][0]
  $leaked_filenames = ['flagtest'] ##$secgen_parameters['leaked_filenames']
  $strings_to_leak = ['this is a list of strings that are secrets / flags','another secret'] ##$secgen_parameters['strings_to_leak']

  ::secgen_functions::leak_files { 'easychat-flag-leak':
    storage_directory => "C:\Users\\${user}\Desktop\\",
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'vagrant',
    leaked_from       => 'easychat_bo',
  }

  file { 'C://EFSSOF~1/EasyCh~1/users/admin':
    ensure  => file,
    content => template('easychat_bo//admin.erb'),
  }
}
