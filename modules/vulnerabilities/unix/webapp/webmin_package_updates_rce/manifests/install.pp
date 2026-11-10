class webmin_package_updates_rce::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $webmin_username = $secgen_parameters['webmin_username'][0]
  $webmin_password = $secgen_parameters['webmin_password'][0]
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $leaked_filenames = $secgen_parameters['leaked_filenames']

  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  # wget fetches the .deb below; apt-show-versions is what the Software Package
  # Updates module (the exploited CGI) uses to enumerate available updates, so
  # install it so the module is fully functional. The Webmin .deb's own
  # dependencies (perl, libnet-ssleay-perl, openssl, libauthen-pam-perl,
  # libpam-runtime, libio-pty-perl, unzip, shared-mime-info, tar) are resolved
  # by the `apt-get install` of the local package below.
  ensure_packages(['wget', 'curl', 'apt-show-versions'])

  # Webmin 1.996 is the last release vulnerable to CVE-2022-36446; the fix
  # shipped in 1.997, and the Metasploit module's AutoCheck treats any version
  # >= 1.997 as not a target, so the version pin here is load-bearing for the
  # exploit. The .deb is 28 MB, so it is downloaded at provision time from the
  # project's stable GitHub release asset rather than bundled in the repo.
  exec { 'download-webmin-1.996':
    command => 'wget -q -O /opt/webmin_1.996_all.deb https://github.com/webmin/webmin/releases/download/1.996/webmin_1.996_all.deb',
    creates => '/opt/webmin_1.996_all.deb',
    timeout => 600,
    require => Package['wget'],
  } ->

  # `apt-get install` of a local .deb path resolves and installs the package's
  # dependencies from the apt repositories. Webmin's postinst runs setup.sh,
  # which generates the config under /etc/webmin, a self-signed certificate, and
  # starts miniserv on port 10000 with SSL enabled.
  exec { 'install-webmin-1.996':
    command     => 'apt-get install -y --no-install-recommends /opt/webmin_1.996_all.deb',
    environment => ['DEBIAN_FRONTEND=noninteractive'],
    creates     => '/usr/share/webmin/version',
    timeout     => 600,
    require     => [Exec['download-webmin-1.996'], Package['apt-show-versions']],
  } ->

  # Set the listening port and create a full-privilege Webmin administrator with
  # the datastore credentials (see files/configure_webmin.sh). Credentials and
  # port are passed through the environment so a generated password is not placed
  # on a shell command line.
  file { '/usr/local/sbin/configure_webmin.sh':
    source => 'puppet:///modules/webmin_package_updates_rce/configure_webmin.sh',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  } ->

  exec { 'configure-webmin-admin':
    command     => '/usr/local/sbin/configure_webmin.sh',
    environment => ["WEBMIN_USER=${webmin_username}",
                    "WEBMIN_PASS=${webmin_password}",
                    "WEBMIN_PORT=${port}"],
    require     => File['/usr/local/sbin/configure_webmin.sh'],
  } ->

  # Make sure miniserv is enabled at boot and running with the new config, so it
  # is serving after the provisioning NIC is torn down and the VM reboots onto
  # its isolated test VLAN. On Debian bookworm the Webmin .deb installs a native
  # systemd unit (webmin.service) and no /etc/init.d/webmin script, so both
  # enable and restart go through systemctl.
  exec { 'enable-webmin':
    command => 'systemctl enable webmin',
    onlyif  => 'test -x /usr/bin/systemctl',
  } ->

  exec { 'restart-webmin':
    command => 'systemctl restart webmin',
    onlyif  => 'test -x /usr/bin/systemctl',
  }

  # Post-exploitation objective: a flag readable only by root, placed in /root
  # (outside any web root, so it cannot be fetched over HTTP). Only the root
  # command execution that the RCE grants can read it.
  ::secgen_functions::leak_files { 'webmin_package_updates_rce':
    storage_directory => '/root',
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'root',
    group             => 'root',
    mode              => '0600',
    leaked_from       => 'webmin_package_updates_rce',
  }
}
