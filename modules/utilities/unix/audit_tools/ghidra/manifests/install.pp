class ghidra::install{

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }
  ensure_packages('zip')

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $debugger_layout = $secgen_parameters['debugger_layout'][0] == 'true'
  $font_size = $secgen_parameters['font_size'][0]

  if $operatingsystem == 'Kali' {
    # Kali: download the current upstream release at build time (Kali's own ghidra package, 12.1.3+ds, crashes in
    # JavaHelp with "view is invalid"). Ghidra 12.x needs a JDK 21+; pin JDK 21, as kali-rolling defaults to newer.
    $ghidra_version = '12.1.4'
    $ghidra_zip     = 'ghidra_12.1.4_PUBLIC_20260921.zip'
    $ghidra_sha256  = 'ddac49f903da9d5bac833e5cc79395098b9c33cfd3279be5f31bd00387d2d4db'
    $ghidra_url     = "https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${ghidra_version}_build/${ghidra_zip}"
    $ghidra_dir     = "/opt/ghidra_${ghidra_version}_PUBLIC"

    ensure_packages(['openjdk-21-jre', 'openjdk-21-jdk', 'curl', 'unzip', 'gdb', 'python3-pip'])

    # ~570MB: no overall puppet timeout (slow links can exceed 30 min); curl instead aborts a stalled transfer
    # (<10KB/s for 5 min) and retries (-C - resumes a partial download, also on a later provision).
    # Skip the download if a verified zip is already present; on an HTTP error (curl 22, e.g. 416 when resuming
    # a complete-but-corrupt file) or a checksum mismatch, delete the zip so the next run starts clean.
    # /var/tmp, not /tmp: kali-rolling (like Debian 13) mounts /tmp as a RAM-backed tmpfs that is too small for the zip
    $zip_path = "/var/tmp/${ghidra_zip}"
    $checksum = "echo '${ghidra_sha256}  ${zip_path}' | sha256sum -c -"
    $download = "curl -fsSL -C - --retry 5 --retry-delay 15 --connect-timeout 60 --speed-limit 10240 --speed-time 300 -o ${zip_path} ${ghidra_url}"
    exec { 'download and unpack ghidra':
      command  => "if ! ${checksum} >/dev/null 2>&1; then ${download}; rc=\$?; if [ \$rc -eq 22 ]; then rm -f ${zip_path}; fi; [ \$rc -eq 0 ] || exit \$rc; ${checksum} || { rm -f ${zip_path}; exit 1; }; fi; unzip -q ${zip_path} -d /opt && rm -f ${zip_path}",
      creates  => $ghidra_dir,
      provider => shell,
      timeout  => 0,
      require  => Package['curl', 'unzip'],
    }

    file { '/opt/ghidra':
      ensure  => link,
      target  => $ghidra_dir,
      require => Exec['download and unpack ghidra'],
    }

    file_line { 'ghidra java home override':
      path    => "${ghidra_dir}/support/launch.properties",
      match   => '^JAVA_HOME_OVERRIDE=',
      line    => 'JAVA_HOME_OVERRIDE=/usr/lib/jvm/java-21-openjdk-amd64',
      require => [Exec['download and unpack ghidra'], Package['openjdk-21-jdk']],
    }

    # Debugger: gdb's *embedded* python needs the bundled ghidragdb/ghidratrace/protobuf wheels (offline install).
    # On kali-rolling gdb can embed a different python than python3/pip3 (e.g. 3.14 vs 3.13), so run pip inside
    # gdb's python via runpy - the same way Ghidra's own launcher installs missing packages. gdb exits 0 even if
    # pip fails, so success is checked by importing the modules inside gdb. --ignore-installed avoids pip trying
    # to remove apt-managed packages (e.g. an older python3-protobuf).
    $pip_args = "'pip', 'install', '--break-system-packages', '--ignore-installed', '--no-index', '-f', '${ghidra_dir}/Ghidra/Debug/Debugger-rmi-trace/pypkg/dist', '-f', '${ghidra_dir}/Ghidra/Debug/Debugger-agent-gdb/pypkg/dist', 'ghidragdb'"
    $gdb_ok   = "gdb -batch -ex \"python import ghidragdb, ghidratrace; print('GHIDRA_GDB_OK')\" 2>/dev/null | grep -q GHIDRA_GDB_OK"
    exec { 'install ghidra gdb debugger python packages':
      command  => "gdb -batch -ex 'python import sys, runpy' -ex \"python sys.argv=[${pip_args}]\" -ex \"python runpy.run_module('pip', run_name='__main__')\" && ${gdb_ok}",
      unless   => $gdb_ok,
      provider => shell,
      require  => [Exec['download and unpack ghidra'], Package['python3-pip', 'gdb']],
    }

    file { '/usr/share/applications/ghidra.desktop':
      content => "[Desktop Entry]\nVersion=1.0\nName=Ghidra\nExec=/opt/ghidra/ghidraRun\nTerminal=false\nType=Application\nStartupNotify=true\nCategories=Development;\nIcon=/opt/ghidra/docs/GhidraClass/Advanced/src/ghidraRight.png\n",
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      require => File['/opt/ghidra'],
    }
  } else {
    if ($operatingsystem == 'Debian') {
      case $operatingsystemrelease {
        /^(12).*/: { # do 12.x bookworm stuff
          ensure_packages(['openjdk-17-jre', 'openjdk-17-jdk', 'gdb', 'python3-pip', 'python3-psutil'])

          # Debugger: Ghidra's gdb launcher puts its own ghidragdb/ghidratrace on PYTHONPATH, but they need protobuf
          # (>=3,<4), which Debian 12 does not otherwise install. Offline install of the wheel Ghidra bundles.
          # gdb embeds the system python3 here, so a system-wide install reaches it.
          exec { 'install protobuf for the ghidra gdb debugger':
            command => 'pip3 install --break-system-packages --no-index --no-deps /opt/ghidra/Ghidra/Debug/Debugger-rmi-trace/pypkg/dist/protobuf-3.20.3-py2.py3-none-any.whl',
            unless  => "python3 -c 'import google.protobuf'",
            require => [File['/opt/ghidra'], Package['python3-pip', 'gdb']],
          }
        }
        /^(9|10).*/: { # do 9.x stretch stuff
          ensure_packages(['openjdk-11-jre', 'openjdk-11-jdk'])
        }
        /^7.*/: { # do 7.x wheezy stuff
          # Will error -- TODO needs repo
          ensure_packages(['openjdk-11-jre', 'openjdk-11-jdk'])
        }
        default: {
        }
      }
    }

    # Debian: bundled 11.1.2 release (existing labs / lab sheets are written against this version)
    file { '/opt/ghidra':
      ensure => directory,
      recurse => true,
      source => 'puppet:///modules/ghidra/release',
      mode   => '0777',
      owner => 'root',
      group => 'root',
    } ->
    file { '/usr/share/applications/ghidra.desktop':
      source => 'puppet:///modules/ghidra/ghidra.desktop',
      mode   => '0644',
      owner => 'root',
      group => 'root',
    }

    # The lab's Debugger layout: Ghidra copies defaultTools/Debugger.tool from Debugger.jar into each user's
    # tool chest on first launch, so replacing it there gives every account the layout, and Tools > Import
    # Default Tools restores it. files/debugger_layout/make_layout.py generates the tool from the stock one.
    if $debugger_layout {
      $debugger_jar = '/opt/ghidra/Ghidra/Debug/Debugger/lib/Debugger.jar'
      $layout_dir = '/opt/ghidra-debugger-layout'
      file { [$layout_dir, "${layout_dir}/defaultTools"]:
        ensure => directory,
        mode   => '0755',
      } ->
      file { "${layout_dir}/defaultTools/Debugger.tool":
        source => 'puppet:///modules/ghidra/debugger_layout/Debugger.tool',
        mode   => '0644',
      } ->
      exec { 'ghidra debugger lab layout':
        command => "zip -q ${debugger_jar} defaultTools/Debugger.tool",
        cwd     => $layout_dir,
        unless  => "python3 -c \"import sys, zipfile; sys.exit(zipfile.ZipFile('${debugger_jar}').read('defaultTools/Debugger.tool') != open('${layout_dir}/defaultTools/Debugger.tool', 'rb').read())\"",
        require => [File['/opt/ghidra'], Package['zip']],
      }
    }

    # Font size: font.size.override sets the interface fonts and font.monospaced the listings and decompiler,
    # so together they match Ghidra's own Ctrl+- / Ctrl+= adjustment, but for every user and every session.
    if $font_size and $font_size != '' {
      file_line { 'ghidra interface font size':
        path    => '/opt/ghidra/support/launch.properties',
        match   => '^VMARGS=-Dfont.size.override=',
        line    => "VMARGS=-Dfont.size.override=${font_size}",
        require => File['/opt/ghidra'],
      }
      file_line { 'ghidra code font size':
        path    => '/opt/ghidra/Ghidra/Framework/Gui/data/gui.theme.properties',
        match   => '^font.monospaced = ',
        line    => "font.monospaced = monospaced-plain-${font_size}",
        require => File['/opt/ghidra'],
      }
    }
  }

  # put `ghidra` on the PATH (ghidraRun resolves its own location via readlink -f, so a symlink works)
  file { '/usr/local/bin/ghidra':
    ensure  => link,
    target  => '/opt/ghidra/ghidraRun',
    require => File['/opt/ghidra'],
  }

}
