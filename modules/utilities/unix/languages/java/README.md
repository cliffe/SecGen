# java

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with the java module](#setup)
    * [Beginning with the java module](#beginning-with-the-java-module)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

## Overview

Installs the correct Java package on various platforms.

## Module Description

The java module can automatically install Java jdk or jre on a wide variety of systems. Java is a base component for many software platforms, but Java system packages don't always follow packaging conventions. The java module simplifies the Java installation process.

## Setup

### Beginning with the java module

To install the correct Java package on your system, include the `java` class: `include java`.

## Usage

The java module installs the correct jdk or jre package on a wide variety of systems. By default, the module installs the jdk package, but you can set different installation parameters as needed. For example, to install jre instead of jdk, you would set the distribution parameter:

```puppet
class { 'java':
  distribution => 'jre',
}
```

To install the latest patch version of Java 8 on CentOS

```puppet
class { 'java' :
  package => 'java-1.8.0-openjdk-devel',
}
```

The defined type `java::download` installs one or more versions of Java SE from a remote url. `java::download` depends on [puppet/archive](https://github.com/voxpupuli/puppet-archive).

To install Java to a non-default basedir (defaults: /usr/lib/jvm for Debian; /usr/java for RedHat):
```puppet
java::download { 'jdk8' :
  ensure  => 'present',
  java_se => 'jdk',
  url     => 'http://myjava.repository/java.tgz",
  basedir => '/custom/java',
}
```

## AdoptOpenJDK

The defined type `java::adopt` installs one or more versions of AdoptOpenJDK Java. `java::adopt` depends on [puppet/archive](https://github.com/voxpupuli/puppet-archive).

```puppet
java::adopt { 'jdk8' :
  ensure  => 'present',
  version => '8',
  java => 'jdk',
}

java::adopt { 'jdk11' :
  ensure  => 'present',
  version => '11',
  java => 'jdk',
}
```

To install a specific release of a AdoptOpenJDK Java version, e.g. 8u202-b08, provide both parameters `version_major` and `version_minor` as follows:

```puppet
java::adopt { 'jdk8' :
  ensure  => 'present',
  version_major => '8u202',
  version_minor => 'b08',
  java => 'jdk',
}
```

To install AdoptOpenJDK Java to a non-default basedir (defaults: /usr/lib/jvm for Debian; /usr/java for RedHat):
```puppet
java::adopt { 'jdk8' :
  ensure  => 'present',
  version_major => '8u202',
  version_minor => 'b08',
  java => 'jdk',
  basedir => '/custom/java',
}
```

To ensure that a custom basedir is a directory before AdoptOpenJDK Java is installed (note: manage separately for custom ownership or perms):
```puppet
java::adopt { 'jdk8' :
  ensure  => 'present',
  version_major => '8u202',
  version_minor => 'b08',
  java => 'jdk',
  manage_basedir => true,
  basedir => '/custom/java',
}
```

## SAP Java (sapjvm / sapmachine)

SAP also offers JVM distributions. They are mostly required for their SAP products. In earlier versions it is called "sapjvm", in newer versions they call it "sapmachine".

The defined type `java::sap` installs one or more versions of sapjvm (if version 7 or 8) or sapmachine (if version > 8) Java. `java::sap` depends on [puppet/archive](https://github.com/voxpupuli/puppet-archive).
By using this defined type with versions 7 or 8 you agree with the EULA presented at https://tools.hana.ondemand.com/developer-license-3_1.txt!

```puppet
java::sap { 'sapjvm8' :
  ensure  => 'present',
  version => '8',
  java => 'jdk',
}

java::sap { 'sapmachine11' :
  ensure  => 'present',
  version => '11',
  java => 'jdk',
}
```

To install a specific release of a SAP Java version, e.g. sapjvm 8.1.063, provide parameter `version_full`:

```puppet
java::sap { 'jdk8' :
  ensure  => 'present',
  version_full => '8.1.063',
  java => 'jdk',
}
```

To install SAP Java to a non-default basedir (defaults: /usr/lib/jvm for Debian; /usr/java for RedHat):
```puppet
java::adopt { 'sapjvm8' :
  ensure  => 'present',
  version_full => '8.1.063',
  java => 'jdk',
  basedir => '/custom/java',
}
```

To ensure that a custom basedir is a directory before SAP Java is installed (note: manage separately for custom ownership or perms):
```puppet
java::adopt { 'sapjvm8' :
  ensure  => 'present',
  version_full => '8.1.063',
  java => 'jdk',
  manage_basedir => true,
  basedir => '/custom/java',
}
```

## Reference

For information on the classes and types, see the [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-java/blob/main/REFERENCE.md). For information on the facts, see below.

### Facts

The java module includes a few facts to describe the version of Java installed on the system:

* `java_major_version`: The major version of Java.
* `java_patch_level`: The patch level of Java.
* `java_version`: The full Java version string.
* `java_default_home`: The absolute path to the java system home directory (only available on Linux). For instance, the `java` executable's path would be `${::java_default_home}/jre/bin/java`. This is slightly different from the "standard" JAVA_HOME environment variable.
* `java_libjvm_path`: The absolute path to the directory containing the shared library `libjvm.so` (only available on Linux). Useful for setting `LD_LIBRARY_PATH` or configuring the dynamic linker.

**Note:** The facts return `nil` if Java is not installed on the system.

## Limitations

For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-java/blob/main/metadata.json)

This module cannot guarantee installation of Java versions that are not available on platform repositories.

This module only manages a singular installation of Java, meaning it is not possible to manage e.g. OpenJDK 7, Oracle Java 7 and Oracle Java 8 in parallel on the same system.

Oracle Java packages are not included in Debian 7 and Ubuntu 12.04/14.04 repositories. To install Java on those systems, you'll need to package Oracle JDK/JRE, and then the module can install the package. For more information on how to package Oracle JDK/JRE, see the [Debian wiki](http://wiki.debian.org/JavaPackage).

This module is officially [supported](https://forge.puppetlabs.com/supported) for the following Java versions and platforms:

OpenJDK is supported on:

* Red Hat Enterprise Linux (RHEL) 5, 6, 7
* CentOS 5, 6, 7
* Oracle Linux 6, 7
* Scientific Linux 6
* Debian 8, 9
* Ubuntu 14.04, 16.04, 18.04, 20.04
* Solaris 11
* SLES 11, 12

Sun Java is supported on:

* Debian 6

Oracle Java is supported on:

* CentOS 6
* CentOS 7
* Red Hat Enterprise Linux (RHEL) 7

AdoptOpenJDK Java is supported on:

* CentOS
* Red Hat Enterprise Linux (RHEL)
* Amazon Linux
* Debian

SAP Java 7 and 8 (=sapjvm) are supported (by SAP) on:

* SLES 12, 15
* Oracle Linux 7, 8
* Red Hat Enterprise Linux (RHEL) 7, 8

(however installations on other distributions mostly also work well)

For SAP Java > 8 (=sapmachine) please refer to the OpenJDK list as it is based on OpenJDK and has no special requirements.


### Known issues

Where Oracle change the format of the URLs to different installer packages, the curl to fetch the package may fail with a HTTP/404 error. In this case, passing a full known good URL using the `url` parameter will allow the module to still be able to install specific versions of the JRE/JDK. Note the `version_major` and `version_minor` parameters must be passed and must match the version downloaded using the known URL in the `url` parameter. 

#### OpenBSD

OpenBSD packages install Java JRE/JDK in a unique directory structure, not linking
the binaries to a standard directory. Because of that, the path to this location
is hardcoded in the `java_version` fact. Whenever you upgrade Java to a newer
version, you have to update the path in this fact.

## Development

Puppet modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. To contribute to Puppet projects, see our [module contribution guide.](https://docs.puppetlabs.com/forge/contributing.html)

## Contributors

The list of contributors can be found at [https://github.com/puppetlabs/puppetlabs-java/graphs/contributors](https://github.com/puppetlabs/puppetlabs-java/graphs/contributors).
