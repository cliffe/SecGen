# Install function for setgid binaries
# -- Modules calling this function must provide a Makefile and any .c files within it's <module_name>/files directory

define secgen_functions::compile_binary_module (
  $source_module_name, # Name of the module that calls this function
  $binary_directory, # Output path of the compiled binary
  $challenge_name, # Name of the challenge / binary
) {

  ensure_packages('build-essential')
  ensure_packages('gcc-multilib')

  $modules_source = "puppet:///modules/$source_module_name"

  # Move contents of the module's files directory into compile directory
  file { "create-$binary_directory-$source_module_name":
    path => $binary_directory,
    ensure  => directory,
    recurse => true,
    source  => $modules_source,
  }

  # Build the binary with gcc
  exec { "gcc_$challenge_name-$binary_directory":
    cwd     => $binary_directory,
    command => "/usr/bin/make",
    require => File["create-$binary_directory-$source_module_name"]
  }
}
