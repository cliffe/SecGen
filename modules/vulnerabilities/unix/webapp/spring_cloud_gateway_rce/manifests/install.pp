# Class: spring_cloud_gateway_rce::install
# Deploys the vulnerable Spring Cloud Gateway 3.1.0 application (a pre-built
# Spring Boot fat jar) and runs it as a dedicated non-root user.
#
# The jar is bundled rather than compiled on the target: SecGen build VMs sit on
# an isolated provisioning network that cannot reliably reach Maven Central, so
# resolving Spring's dependencies during puppet apply failed with "Network is
# unreachable". files/build/ holds the pom.xml and source the jar was built
# from (see files/build/README.md).
class spring_cloud_gateway_rce::install {
  Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }

  $modulename = 'spring_cloud_gateway_rce'
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $user = $secgen_parameters['unix_username'][0]
  $user_home = "/home/${user}"
  $app_dir = '/opt/scg'

  # default-jdk-headless is OpenJDK 17 on bookworm. A JRE alone would run the
  # jar, but the JDK also ships the `jar` tool the secgen_test uses to confirm
  # the bundled gateway is the vulnerable 3.1.0. The jar is built for Java 11
  # and runs on 17.
  ensure_packages(['default-jdk-headless'])

  user { $user:
    ensure     => present,
    home       => $user_home,
    managehome => true,
  }

  file { $app_dir:
    ensure => directory,
  }

  file { "${app_dir}/scg-gateway.jar":
    ensure  => file,
    source  => "puppet:///modules/${modulename}/scg-gateway.jar",
    owner   => $user,
    mode    => '0644',
    require => [File[$app_dir], User[$user]],
  }
}
