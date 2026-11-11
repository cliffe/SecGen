# Installs QEMU, libvirt and build tools, plus a Debian cloud image for disposable guests.
class qemu_kvm_devbox::install {
  Exec { path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'] }

  $packages = ['qemu-system-x86', 'qemu-utils', 'libvirt-daemon-system', 'virtinst', 'cloud-image-utils',
               'ruby', 'git', 'build-essential', 'wget']
  ensure_packages($packages)

  file { ['/var/lib/devbox', '/var/lib/devbox/images']:
    ensure => directory,
    mode   => '0755',
  }

  # The "latest" directory is rebuilt upstream, so the image is verified against its own checksum list.
  $image_url = 'https://cloud.debian.org/images/cloud/bookworm/latest'
  # The generic image has the full kernel; the genericcloud kernel omits many hardware drivers.
  $image     = 'debian-12-generic-amd64.qcow2'
  exec { 'download debian cloud image':
    command  => "wget -q ${image_url}/${image} ${image_url}/SHA512SUMS && sha512sum --ignore-missing -c SHA512SUMS && rm SHA512SUMS",
    cwd      => '/var/lib/devbox/images',
    provider => shell,
    creates  => "/var/lib/devbox/images/${image}",
    timeout  => 1800,
    require  => [File['/var/lib/devbox/images'], Package['wget']],
  }

  # Runs after any base rule that sets a blanket group, and survives the udev events
  # KVM raises whenever a guest starts or stops.
  file { '/etc/udev/rules.d/99-devbox-kvm.rules':
    ensure  => file,
    content => "KERNEL==\"kvm\", GROUP=\"kvm\", MODE=\"0660\"\n",
    mode    => '0644',
  }

  file { '/usr/local/bin/devbox-check':
    ensure => file,
    source => 'puppet:///modules/qemu_kvm_devbox/devbox-check',
    mode   => '0755',
  }

  file { '/usr/local/bin/devbox-new-target':
    ensure => file,
    source => 'puppet:///modules/qemu_kvm_devbox/devbox-new-target',
    mode   => '0755',
  }
}
