# Installs Volatility 3 into a venv (PEP 668 blocks system pip on Debian 12) and
# installs the bundled Linux symbol tables (ISFs). All bundled ISFs are placed in
# Volatility's symbol path; Volatility matches the right one to a memory image by
# its kernel banner at analysis time.
#
# The ISF must match the kernel of the captured image. The lab VMs reboot into
# the newest kernel the update module installs, so the ISF has to cover that
# POST-reboot kernel, not the one running during provisioning. Puppet runs before
# that reboot and so can't see the final kernel; the module's secgen_test runs
# after it and fails if no bundled ISF covers the running kernel (see the test).
class volatility3::install {
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  ensure_packages(['python3-pip', 'python3-venv', 'git'])

  exec { 'create volatility3 venv':
    command => 'python3 -m venv /opt/volatility3',
    creates => '/opt/volatility3/bin/python',
    require => Package['python3-venv'],
  }

  exec { 'pip install volatility3':
    command => '/opt/volatility3/bin/pip install --upgrade pip volatility3',
    creates => '/opt/volatility3/bin/vol',
    timeout => 0,
    require => Exec['create volatility3 venv'],
  }

  ['vol', 'volshell'].each |$entrypoint| {
    file { "/usr/local/bin/${entrypoint}":
      ensure  => link,
      target  => "/opt/volatility3/bin/${entrypoint}",
      require => Exec['pip install volatility3'],
    }
  }

  # Stage the bundled ISFs (+ banner sidecars, used by the test).
  file { '/opt/volatility3/isf':
    ensure  => directory,
    source  => 'puppet:///modules/volatility3/isf',
    recurse => true,
    purge   => false,
  }

  # Install every bundled ISF into Volatility's symbol path; it auto-selects the
  # one whose banner matches whichever memory image is analysed.
  exec { 'install volatility ISFs':
    command  => 'VOL_SYM=$(/opt/volatility3/bin/python -c "import volatility3, os; print(os.path.join(os.path.dirname(volatility3.__file__), \'symbols\', \'linux\'))") && mkdir -p "$VOL_SYM" && cp /opt/volatility3/isf/*.json.xz "$VOL_SYM/"',
    provider => 'shell',
    require  => [Exec['pip install volatility3'], File['/opt/volatility3/isf']],
  }
}
