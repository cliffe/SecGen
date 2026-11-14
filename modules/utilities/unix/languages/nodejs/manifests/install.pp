# Node.js and npm from a pinned upstream release tarball, unpacked under /opt with the executables symlinked
# onto the default PATH. The distro package is deliberately not used: Kali's nodejs candidate sits a patch
# release or two behind, which is enough to fail the engines range of npm packages that pin a minimum minor.
class nodejs::install {
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  $node_version    = $secgen_parameters['node_version'][0]
  $node_sha256     = $secgen_parameters['node_sha256'][0]
  $global_packages = $secgen_parameters['global_packages']

  $node_dir = "/opt/node-v${node_version}-linux-x64"
  $tarball  = "node-v${node_version}-linux-x64.tar.xz"
  # /var/tmp rather than /tmp: kali-rolling mounts /tmp as a tmpfs sized at half of RAM
  $tar_path = "/var/tmp/${tarball}"
  $url      = "https://nodejs.org/dist/v${node_version}/${tarball}"

  ensure_packages(['curl', 'xz-utils'])

  $checksum = "echo '${node_sha256}  ${tar_path}' | sha256sum -c -"
  $download = "curl -fsSL -C - --retry 5 --retry-delay 15 --connect-timeout 60 --speed-limit 10240 --speed-time 300 -o ${tar_path} ${url}"

  # Resume a part-download; if the server refuses the range request (curl 22) the stale file is dropped so the
  # next attempt starts clean. A tarball failing the checksum is removed rather than left to be resumed.
  exec { 'download and unpack node':
    command  => "if ! ${checksum} >/dev/null 2>&1; then ${download}; rc=\$?; if [ \$rc -eq 22 ]; then rm -f ${tar_path}; fi; [ \$rc -eq 0 ] || exit \$rc; ${checksum} || { rm -f ${tar_path}; exit 1; }; fi; tar -xJf ${tar_path} -C /opt && rm -f ${tar_path}",
    creates  => $node_dir,
    provider => shell,
    timeout  => 0,
    require  => Package['curl', 'xz-utils'],
  }

  # /opt/node follows whichever version is installed, so the /usr/local/bin links survive a version change
  file { '/opt/node':
    ensure  => link,
    target  => $node_dir,
    require => Exec['download and unpack node'],
  }

  ['node', 'npm', 'npx'].each |$bin| {
    file { "/usr/local/bin/${bin}":
      ensure  => link,
      target  => "/opt/node/bin/${bin}",
      require => File['/opt/node'],
    }
  }

  # Without this, a global install lands in /opt/node/bin, which is on nobody's PATH. /usr/local/bin is, so
  # point npm's prefix there and the executables appear where a student would expect them.
  file { '/etc/npmrc':
    ensure  => file,
    content => "prefix=/usr/local\n",
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }

  unless $global_packages == undef {
    $wanted = $global_packages.filter |$pkg| { $pkg != '' }
    $wanted.each |$pkg| {
      # Strip any @<version> suffix to get the directory npm installs into, keeping a leading @scope
      $pkg_name = regsubst($pkg, '^(@?[^@]+).*$', '\1')
      exec { "npm install -g ${pkg}":
        command => "npm install -g --no-fund --no-audit ${pkg}",
        creates => "/usr/local/lib/node_modules/${pkg_name}",
        timeout => 1800,
        require => [File['/usr/local/bin/npm'], File['/etc/npmrc']],
      }
    }
  }
}
