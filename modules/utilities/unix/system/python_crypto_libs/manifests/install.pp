class python_crypto_libs::install{
  package { ['python3-pip', 'python3-numpy', 'python3-pycryptodome']:
    ensure => 'installed',
  }

  # The Debian package should provide the `Crypto` namespace, but on the
  # Proxmox bookworm KDE base `from Crypto.Cipher import AES` failed after the
  # package installed (run 2026-10-22-i242-d6ccc5). If the import still fails,
  # install pycryptodome from PyPI. Debian 12 marks the system Python as
  # externally managed (PEP 668), hence --break-system-packages.
  exec { 'pycryptodome-pip-fallback':
    command  => 'python3 -m pip install --break-system-packages pycryptodome',
    unless   => 'python3 -c "from Crypto.Cipher import AES"',
    provider => shell,
    path     => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    require  => Package['python3-pip', 'python3-pycryptodome'],
  }
}
