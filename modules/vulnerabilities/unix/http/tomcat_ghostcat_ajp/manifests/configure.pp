# Class: tomcat_ghostcat_ajp::configure
# Expose the AJP connector (Ghostcat, CVE-2020-1938) and plant a WEB-INF flag.
#
class tomcat_ghostcat_ajp::configure {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $strings_to_leak   = $secgen_parameters['strings_to_leak']
  $leaked_filenames  = $secgen_parameters['leaked_filenames']

  $catalina_base = '/opt/tomcat'
  $webinf_dir    = "${catalina_base}/webapps/ROOT/WEB-INF"

  # The Tomcat service module (services/unix/http/tomcat) is a separate SecGen
  # module, so its Puppet runs in its own catalogue - this module cannot
  # reference Tomcat::Install or Service['tomcat'] directly. SecGen's <requires>
  # ordering guarantees Tomcat is already installed and running by the time this
  # runs, so we edit the installed files and restart the service ourselves.

  # Replace server.xml with one whose AJP connector is bound to 0.0.0.0:8009,
  # requires no secret and allows arbitrary request attributes. This is the
  # pre-9.0.31 Ghostcat behaviour, restored on the installed (patched) release.
  # Augeas is avoided on purpose: installing ruby-augeas and using the augeas
  # provider in the same Puppet run is unreliable, so ship the whole file.
  file { "${catalina_base}/conf/server.xml":
    ensure => file,
    owner  => 'tomcat',
    group  => 'tomcat',
    mode   => '0640',
    source => 'puppet:///modules/tomcat_ghostcat_ajp/server.xml',
    notify => Exec['restart tomcat for ghostcat ajp'],
  }

  # Plant the flag under WEB-INF: unreachable over HTTP, readable through the
  # Ghostcat AJP file read. leak_files creates the directory tree and chowns it
  # to the tomcat user so the service can read the file back.
  ::secgen_functions::leak_files { 'tomcat-ghostcat-webinf-leak':
    storage_directory => $webinf_dir,
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'tomcat',
    group             => 'tomcat',
    mode              => '0640',
    leaked_from       => 'tomcat_ghostcat_ajp',
    notify            => Exec['restart tomcat for ghostcat ajp'],
  }

  # Restart Tomcat so the exposed AJP connector binds and the planted file is in
  # place. refreshonly: only fires when server.xml or the leaked file change.
  exec { 'restart tomcat for ghostcat ajp':
    command     => '/bin/systemctl restart tomcat',
    refreshonly => true,
    path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
  }
}
