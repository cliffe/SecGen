# On Debian systems, if alternatives are set, manually assign them.
class java::config ( ) {
  case $::osfamily {
    'Debian': {
      if $java::use_java_alternative != undef and $java::use_java_alternative_path != undef {
        exec { 'update-java-alternatives':
          path    => '/usr/bin:/usr/sbin:/bin:/sbin',
          command => "update-java-alternatives --set ${java::use_java_alternative} ${java::jre_flag}",
          unless  => "test /etc/alternatives/java -ef '${java::use_java_alternative_path}'",
        }
      }
      if $java::use_java_home != undef {
        file_line { 'java-home-environment':
          path  => '/etc/environment',
          line  => "JAVA_HOME=${$java::use_java_home}",
          match => 'JAVA_HOME=',
        }
      }
    }
    'RedHat': {
      if $java::use_java_alternative != undef and $java::use_java_alternative_path != undef {
        # The standard packages install alternatives, custom packages do not
        # For the stanard packages java::params needs these added.
        if $java::use_java_package_name != $java::default_package_name {
          exec { 'create-java-alternatives':
            path    => '/usr/bin:/usr/sbin:/bin:/sbin',
            command => "alternatives --install /usr/bin/java java ${$java::use_java_alternative_path} 20000" ,
            unless  => "alternatives --display java | grep -q ${$java::use_java_alternative_path}",
            before  => Exec['update-java-alternatives']
          }
        }

        exec { 'update-java-alternatives':
          path    => '/usr/bin:/usr/sbin',
          command => "alternatives --set java ${$java::use_java_alternative_path}" ,
          unless  => "test /etc/alternatives/java -ef '${java::use_java_alternative_path}'",
        }
      }
      if $java::use_java_home != undef {
        file_line { 'java-home-environment':
          path  => '/etc/environment',
          line  => "JAVA_HOME=${$java::use_java_home}",
          match => 'JAVA_HOME=',
        }
      }
    }
    'FreeBSD', 'Suse': {
      if $java::use_java_home != undef {
        file_line { 'java-home-environment':
          path  => '/etc/environment',
          line  => "JAVA_HOME=${$java::use_java_home}",
          match => 'JAVA_HOME=',
        }
      }
    }
    'Solaris': {
      if $java::use_java_home != undef {
        file_line { 'java-home-environment':
          path  => '/etc/profile',
          line  => "JAVA_HOME=${$java::use_java_home}",
          match => 'JAVA_HOME=',
        }
      }
    }
    'Archlinux': {
      if $java::use_java_home != undef {
        file_line { 'java-home-environment':
          path  => '/etc/profile',
          line  => "JAVA_HOME=${$java::use_java_home}",
          match => 'JAVA_HOME=',
        }
      }
    }
    default: {
      # Do nothing.
    }
  }
}
