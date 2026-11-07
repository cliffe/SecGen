# Lets the listed accounts use KVM and libvirt without root.
class qemu_kvm_devbox::config {
  require qemu_kvm_devbox::install

  Exec { path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'] }

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $accounts = $secgen_parameters['accounts']

  unless $accounts == undef {
    $accounts.each |$raw_account| {
      $account  = parsejson($raw_account)
      $username = $account['username']

      exec { "add ${username} to kvm and libvirt":
        command  => "usermod -aG kvm,libvirt ${username}",
        unless   => "id -nG ${username} | grep -qw kvm && id -nG ${username} | grep -qw libvirt",
        provider => shell,
      }
    }
  }
}
