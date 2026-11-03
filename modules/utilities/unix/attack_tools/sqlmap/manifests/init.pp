class sqlmap (
  $installdir = '/usr/share/sqlmap',
  $source = 'https://github.com/sqlmapproject/sqlmap.git',
  $path = '/usr/local/bin',
  $revision = 'HEAD',
) {

  # git to clone; sqlmap.py's shebang is '#!/usr/bin/env python', which bookworm
  # only provides via python-is-python3
  ensure_packages(['git', 'python3', 'python-is-python3'])

  # Create directory to install into
  file { $installdir:
    ensure => directory,
  }

  # Clone sqlmap from Github using 'exec' resource
  exec { 'clone_sqlmap':
    command => "git clone ${source} ${installdir}",
    path    => ['/usr/bin', '/bin', '/usr/local/bin'],
    creates => "${installdir}/sqlmap.py",
    require => [File[$installdir], Package['git']],
  }

  # Symlink the main script into a bin dir
  file { "${path}/sqlmap":
    ensure  => link,
    target  => "${installdir}/sqlmap.py",
    require => Exec['clone_sqlmap'],
  }
}
