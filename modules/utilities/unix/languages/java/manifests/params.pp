# @summary
#   This class builds a hash of JDK/JRE packages and (for Debian)
#   alternatives.  For wheezy/precise, we provide Oracle JDK/JRE
#   options, even though those are not in the package repositories.
#
# @api private
class java::params {

  case $facts['os']['family'] {
    'RedHat': {
      case $facts['os']['name'] {
        'RedHat', 'CentOS', 'OracleLinux', 'Scientific', 'OEL', 'SLC', 'CloudLinux': {
          if (versioncmp($facts['os']['release']['full'], '5.0') < 0) {
            $jdk_package = 'java-1.6.0-sun-devel'
            $jre_package = 'java-1.6.0-sun'
            $java_home   = '/usr/lib/jvm/java-1.6.0-sun/jre/'
          }
          # See cde7046 for why >= 5.0 < 6.3
          elsif (versioncmp($facts['os']['release']['full'], '6.3') < 0) {
            $jdk_package = 'java-1.6.0-openjdk-devel'
            $jre_package = 'java-1.6.0-openjdk'
            $java_home   = '/usr/lib/jvm/java-1.6.0/'
          }
          # See PR#160 / c8e46b5 for why >= 6.3 < 7.1
          elsif (versioncmp($facts['os']['release']['full'], '7.1') < 0) {
            $jdk_package = 'java-1.7.0-openjdk-devel'
            $jre_package = 'java-1.7.0-openjdk'
            $java_home   = '/usr/lib/jvm/java-1.7.0/'
          }
          else {
            $jdk_package = 'java-1.8.0-openjdk-devel'
            $jre_package = 'java-1.8.0-openjdk'
            $java_home   = '/usr/lib/jvm/java-1.8.0/'
          }
        }
        'Fedora': {
          if (versioncmp($facts['os']['release']['full'], '21') < 0) {
            $jdk_package = 'java-1.7.0-openjdk-devel'
            $jre_package = 'java-1.7.0-openjdk'
            $java_home   = "/usr/lib/jvm/java-1.7.0-openjdk-${facts['os']['architecture']}/"
          }
          else {
            $jdk_package = 'java-1.8.0-openjdk-devel'
            $jre_package = 'java-1.8.0-openjdk'
            $java_home   = "/usr/lib/jvm/java-1.8.0-openjdk-${facts['os']['architecture']}/"
          }
        }
        'Amazon': {
          $jdk_package = 'java-1.7.0-openjdk-devel'
          $jre_package = 'java-1.7.0-openjdk'
          $java_home   = "/usr/lib/jvm/java-1.7.0-openjdk-${facts['os']['architecture']}/"
        }
        default: { fail("unsupported os ${facts['os']['name']}") }
      }
      $java = {
        'jdk' => {
          'package'   => $jdk_package,
          'java_home' => $java_home,
        },
        'jre' => {
          'package'   => $jre_package,
          'java_home' => $java_home,
        },
      }
    }
    'Debian': {
      $oracle_architecture = $facts['os']['architecture'] ? {
        'amd64' => 'x64',
        default => $facts['os']['architecture']
      }
      $openjdk_architecture = $facts['os']['architecture'] ? {
        'aarch64' => 'arm64',
        'armv7l'  => 'armhf',
        default   => $facts['os']['architecture']
      }
      case $facts['os']['release']['major'] {
        '7', '8', '14.04': {
          $java =  {
            'jdk' => {
              'package'          => 'openjdk-7-jdk',
              'alternative'      => "java-1.7.0-openjdk-${openjdk_architecture}",
              'alternative_path' => "/usr/lib/jvm/java-1.7.0-openjdk-${openjdk_architecture}/bin/java",
              'java_home'        => "/usr/lib/jvm/java-1.7.0-openjdk-${openjdk_architecture}/",
            },
            'jre' => {
              'package'          => 'openjdk-7-jre-headless',
              'alternative'      => "java-1.7.0-openjdk-${facts['os']['architecture']}",
              'alternative_path' => "/usr/lib/jvm/java-1.7.0-openjdk-${openjdk_architecture}/bin/java",
              'java_home'        => "/usr/lib/jvm/java-1.7.0-openjdk-${openjdk_architecture}/",
            },
            'oracle-jre' => {
              'package'          => 'oracle-j2re1.7',
              'alternative'      => 'j2re1.7-oracle',
              'alternative_path' => '/usr/lib/jvm/j2re1.7-oracle/bin/java',
              'java_home'        => '/usr/lib/jvm/j2re1.7-oracle/',
            },
            'oracle-jdk' => {
              'package'          => 'oracle-j2sdk1.7',
              'alternative'      => 'j2sdk1.7-oracle',
              'alternative_path' => '/usr/lib/jvm/j2sdk1.7-oracle/jre/bin/java',
              'java_home'        => '/usr/lib/jvm/j2sdk1.7-oracle/jre/',
            },
            'oracle-j2re' => {
              'package'          => 'oracle-j2re1.8',
              'alternative'      => 'j2re1.8-oracle',
              'alternative_path' => '/usr/lib/jvm/j2re1.8-oracle/bin/java',
              'java_home'        => '/usr/lib/jvm/j2re1.8-oracle/',
            },
            'oracle-j2sdk' => {
              'package'          => 'oracle-j2sdk1.8',
              'alternative'      => 'j2sdk1.8-oracle',
              'alternative_path' => '/usr/lib/jvm/j2sdk1.8-oracle/bin/java',
              'java_home'        => '/usr/lib/jvm/j2sdk1.8-oracle/',
            },
            'oracle-java8-jre' => {
              'package'          => 'oracle-java8-jre',
              'alternative'      => "jre-8-oracle-${oracle_architecture}",
              'alternative_path' => "/usr/lib/jvm/jre-8-oracle-${oracle_architecture}/bin/java",
              'java_home'        => "/usr/lib/jvm/jre-8-oracle-${oracle_architecture}/",
            },
            'oracle-java8-jdk' => {
              'package'          => 'oracle-java8-jdk',
              'alternative'      => "jdk-8-oracle-${oracle_architecture}",
              'alternative_path' => "/usr/lib/jvm/jdk-8-oracle-${oracle_architecture}/bin/java",
              'java_home'        => "/usr/lib/jvm/jdk-8-oracle-${oracle_architecture}/",
            },
          }
        }
        '9', '15.04', '15.10', '16.04', '16.10', '17.04', '17.10': {
          $java =  {
            'jdk' => {
              'package'          => 'openjdk-8-jdk',
              'alternative'      => "java-1.8.0-openjdk-${openjdk_architecture}",
              'alternative_path' => "/usr/lib/jvm/java-1.8.0-openjdk-${openjdk_architecture}/bin/java",
              'java_home'        => "/usr/lib/jvm/java-1.8.0-openjdk-${openjdk_architecture}/",
            },
            'jre' => {
              'package'          => 'openjdk-8-jre-headless',
              'alternative'      => "java-1.8.0-openjdk-${openjdk_architecture}",
              'alternative_path' => "/usr/lib/jvm/java-1.8.0-openjdk-${openjdk_architecture}/bin/java",
              'java_home'        => "/usr/lib/jvm/java-1.8.0-openjdk-${openjdk_architecture}/",
            },
          }
        }
        '10', '18.04', '18.10', '19.04', '19.10', '20.04': {
          $java =  {
            'jdk' => {
              'package'          => 'openjdk-11-jdk',
              'alternative'      => "java-1.11.0-openjdk-${openjdk_architecture}",
              'alternative_path' => "/usr/lib/jvm/java-1.11.0-openjdk-${openjdk_architecture}/bin/java",
              'java_home'        => "/usr/lib/jvm/java-1.11.0-openjdk-${openjdk_architecture}/",
            },
            'jre' => {
              'package'          => 'openjdk-11-jre-headless',
              'alternative'      => "java-1.11.0-openjdk-${openjdk_architecture}",
              'alternative_path' => "/usr/lib/jvm/java-1.11.0-openjdk-${openjdk_architecture}/bin/java",
              'java_home'        => "/usr/lib/jvm/java-1.11.0-openjdk-${openjdk_architecture}/",
            },
          }
        }
        '11': {
          $java =  {
            'jdk' => {
              'package'          => 'openjdk-11-jdk',
              'alternative'      => "java-1.11.0-openjdk-${openjdk_architecture}",
              'alternative_path' => "/usr/lib/jvm/java-1.11.0-openjdk-${openjdk_architecture}/bin/java",
              'java_home'        => "/usr/lib/jvm/java-1.11.0-openjdk-${openjdk_architecture}/",
            },
            'jre' => {
              'package'          => 'openjdk-11-jre-headless',
              'alternative'      => "java-1.11.0-openjdk-${openjdk_architecture}",
              'alternative_path' => "/usr/lib/jvm/java-1.11.0-openjdk-${openjdk_architecture}/bin/java",
              'java_home'        => "/usr/lib/jvm/java-1.11.0-openjdk-${openjdk_architecture}/",
            },
          }
        }
        '12': {
          $java =  {
            'jdk' => {
              'package'          => 'openjdk-17-jdk',
              'alternative'      => "java-1.17.0-openjdk-${openjdk_architecture}",
              'alternative_path' => "/usr/lib/jvm/java-1.17.0-openjdk-${openjdk_architecture}/bin/java",
              'java_home'        => "/usr/lib/jvm/java-1.17.0-openjdk-${openjdk_architecture}/",
            },
            'jre' => {
              'package'          => 'openjdk-17-jre-headless',
              'alternative'      => "java-1.17.0-openjdk-${openjdk_architecture}",
              'alternative_path' => "/usr/lib/jvm/java-1.17.0-openjdk-${openjdk_architecture}/bin/java",
              'java_home'        => "/usr/lib/jvm/java-1.17.0-openjdk-${openjdk_architecture}/",
            },
          }
        }
        default: { fail("unsupported release ${facts['os']['release']['major']}") }
      }
    }
    'OpenBSD': {
      $java = {
        'jdk' => {
          'package'   => 'jdk',
          'java_home' => '/usr/local/jdk/',
        },
        'jre' => {
          'package'   => 'jre',
          'java_home' => '/usr/local/jdk/',
        },
      }
    }
    'FreeBSD': {
      $java = {
        'jdk' => {
          'package'   => 'openjdk',
          'java_home' => '/usr/local/openjdk7/',
        },
        'jre' => {
          'package'   => 'openjdk-jre',
          'java_home' => '/usr/local/openjdk7/',
        },
      }
    }
    'Solaris': {
      $java = {
        'jdk' => {
          'package'   => 'developer/java/jdk-7',
          'java_home' => '/usr/jdk/instances/jdk1.7.0/',
        },
        'jre' => {
          'package'   => 'runtime/java/jre-7',
          'java_home' => '/usr/jdk/instances/jdk1.7.0/',
        },
      }
    }
    'Suse': {
      case $facts['os']['name'] {
        'SLES': {
          if (versioncmp($facts['os']['release']['full'], '12.1') >= 0) {
            $jdk_package = 'java-1_8_0-openjdk-devel'
            $jre_package = 'java-1_8_0-openjdk'
            $java_home   = '/usr/lib64/jvm/java-1.8.0-openjdk-1.8.0/'
          } elsif (versioncmp($facts['os']['release']['full'], '12') >= 0) {
            $jdk_package = 'java-1_7_0-openjdk-devel'
            $jre_package = 'java-1_7_0-openjdk'
            $java_home   = '/usr/lib64/jvm/java-1.7.0-openjdk-1.7.0/'
          } elsif (versioncmp($facts['os']['release']['full'], '11.4') >= 0) {
            $jdk_package = 'java-1_7_1-ibm-devel'
            $jre_package = 'java-1_7_1-ibm'
            $java_home   = '/usr/lib64/jvm/java-1.7.1-ibm-1.7.1/'
          } else {
            $jdk_package = 'java-1_6_0-ibm-devel'
            $jre_package = 'java-1_6_0-ibm'
            $java_home   = '/usr/lib64/jvm/java-1.6.0-ibm-1.6.0/'
          }
        }
        'OpenSuSE': {
          $jdk_package = 'java-1_7_0-openjdk-devel'
          $jre_package = 'java-1_7_0-openjdk'
          $java_home   = '/usr/lib64/jvm/java-1.7.0-openjdk-1.7.0/'
        }
        default: {
          $jdk_package = 'java-1_6_0-ibm-devel'
          $jre_package = 'java-1_6_0-ibm'
          $java_home   = '/usr/lib64/jvm/java-1.6.0-ibd-1.6.0/'
        }
      }
      $java = {
        'jdk' => {
          'package'   => $jdk_package,
          'java_home' => $java_home,
        },
        'jre' => {
          'package'   => $jre_package,
          'java_home' => $java_home,
        },
      }
    }
    'Archlinux': {
      $jdk_package = 'jdk8-openjdk'
      $jre_package = 'jre8-openjdk'
      $java_home   = '/usr/lib/jvm/java-8-openjdk/jre/'
      $java = {
        'jdk' => {
          'package'   => $jdk_package,
          'java_home' => $java_home,
        },
        'jre' => {
          'package'   => $jre_package,
          'java_home' => $java_home,
        },
      }
    }
    default: { fail("unsupported platform ${facts['os']['family']}") }
  }
}
