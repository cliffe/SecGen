# Class: minimal_log4j_webapp::install
# Fetch an early JDK 8 and log4j 2.14.1, deploy the plain-Java web app source,
# and compile it on the target. No Maven/Gradle: the app is a single source
# file compiled with the fetched JDK's javac.
class minimal_log4j_webapp::install {
  Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }
  $modulename = 'minimal_log4j_webapp'

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $user = $secgen_parameters['unix_username'][0]
  $user_home = "/home/${user}"

  $app_dir = '/opt/minimal_log4j_webapp'
  $lib_dir = "${app_dir}/lib"
  $src_dir = "${app_dir}/src/com/secgen"
  $classes_dir = "${app_dir}/classes"
  $jdk_dir = '/opt/jdk8u181'
  $javac = "${jdk_dir}/bin/javac"

  # log4j 2.14.1 still resolves message lookups by default; commons-collections
  # 3.2.1 (not 3.2.2, which blocks functor deserialisation) is the gadget the
  # JNDI/LDAP path deserialises.
  $log4j_core = "${lib_dir}/log4j-core-2.14.1.jar"
  $log4j_api = "${lib_dir}/log4j-api-2.14.1.jar"
  $commons = "${lib_dir}/commons-collections-3.2.1.jar"

  user { $user:
    ensure     => present,
    home       => $user_home,
    managehome => true,
  }

  ensure_packages(['wget', 'ca-certificates'])

  file { [$app_dir, $lib_dir, "${app_dir}/src", "${app_dir}/src/com", $src_dir, $classes_dir]:
    ensure  => directory,
    mode    => '0755',
    require => Package['wget'],
  }

  # Early JDK 8 (8u181). Run the app under this JDK, not the base JRE.
  exec { 'download-jdk8':
    cwd     => '/opt',
    command => 'wget -q -O /opt/jdk8u181.tar.gz https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u181-b13/OpenJDK8U-jdk_x64_linux_hotspot_8u181b13.tar.gz',
    creates => '/opt/jdk8u181.tar.gz',
    timeout => 600,
    require => Package['wget'],
  }
  -> exec { 'extract-jdk8':
    cwd     => '/opt',
    command => 'tar -xzf /opt/jdk8u181.tar.gz',
    creates => '/opt/jdk8u181-b13',
    timeout => 300,
  }
  -> exec { 'move-jdk8':
    command => "mv /opt/jdk8u181-b13 ${jdk_dir}",
    creates => $jdk_dir,
  }

  # log4j + gadget jars straight from Maven Central (fast here).
  exec { 'download-log4j-core':
    command => "wget -q -O ${log4j_core} https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.14.1/log4j-core-2.14.1.jar",
    creates => $log4j_core,
    timeout => 300,
    require => File[$lib_dir],
  }
  exec { 'download-log4j-api':
    command => "wget -q -O ${log4j_api} https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/2.14.1/log4j-api-2.14.1.jar",
    creates => $log4j_api,
    timeout => 300,
    require => File[$lib_dir],
  }
  exec { 'download-commons-collections':
    command => "wget -q -O ${commons} https://repo1.maven.org/maven2/commons-collections/commons-collections/3.2.1/commons-collections-3.2.1.jar",
    creates => $commons,
    timeout => 300,
    require => File[$lib_dir],
  }

  # App source and log4j config.
  file { "${src_dir}/App.java":
    ensure  => file,
    source  => "puppet:///modules/${modulename}/App.java",
    mode    => '0644',
    require => File[$src_dir],
  }
  file { "${app_dir}/log4j2.xml":
    ensure  => file,
    source  => "puppet:///modules/${modulename}/log4j2.xml",
    mode    => '0644',
    require => File[$app_dir],
  }

  # Compile on the target with the fetched JDK 8.
  exec { 'compile-app':
    command => "${javac} -cp ${log4j_api}:${log4j_core} -d ${classes_dir} ${src_dir}/App.java",
    creates => "${classes_dir}/com/secgen/App.class",
    timeout => 300,
    require => [Exec['move-jdk8'], Exec['download-log4j-core'], Exec['download-log4j-api'],
                File["${src_dir}/App.java"], File[$classes_dir]],
  }
  -> exec { 'chown-app':
    command => "chown -R ${user}:${user} ${app_dir}",
    require => User[$user],
  }
}
