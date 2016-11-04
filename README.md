# Security Scenario Generator (SecGen)

## Summary
SecGen is a Ruby application that uses virtualization software to create vulnerable virtual machines so students can learn security penetration testing techniques. 

Boxes like Metasploitable2 are always the same, this project uses Vagrant, Puppet, and Ruby to quickly create randomly vulnerable virtual machines that can be used for learning or CTF events. 

## Introduction
Computer security students benefit from engaging in hacking challenges. Practical lab work and pre-configured hacking challenges are common practice both in security education and also as a pastime for security-minded individuals. Competitive hacking challenges, such as capture the flag (CTF) competitions have become a mainstay at industry conferences and are the focus of large online communities. Virtual machines (VMs) provide an effective way of sharing targets for hacking, and can be designed in order to test the skills of the attacker. Websites such as Vulnhub host pre-configured hacking challenge VMs and are a valuable resource for those learning and advancing their skills in computer security. However, developing these hacking challenges is time consuming, and once created, essentially static. That is, once the challenge has been "solved" there is no remaining challenge for the student, and if the challenge is created for a competition or assessment, the challenge cannot be reused without risking plagiarism, and collusion. 

Security Scenario Generator (SecGen) generates randomised vulnerable systems. VMs are created based on a scenario specification, which describes the constraints and properties of the VMs to be created. For example, a scenario could specify the creation of a system with a remotely exploitable vulnerability that would result in user-level compromise, and a locally exploitable flaw that would result in root-level compromise. This would require the attacker to discover and exploit both randomly selected vulnerabilities in order to obtain root access to the system. Alternatively, the scenario that is defined can be more specific, specifying certain kinds of services (such as FTP or SMB) or even exact vulnerabilities (by CVE).

SecGen is a Ruby application, with an XML configuration language. SecGen reads its configuration, including the available vulnerabilities, services, networks, users, and content, reads the definition of the requested scenario, applies logic for randomising the scenario, and leverages Puppet and Vagrant to provision the required VMs.

## License
SecGen is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

SecGen contains modules, which install various software packages. Each SecGen module may contain or remotely source software, and each module defines its own license in the accompanying secgen_metadata.xml file.

## Installation
You will need to install the following:

Ruby: https://www.ruby-lang.org/en/  
Vagrant: http://www.vagrantup.com/  
Virtual Box: https://www.virtualbox.org/  
Puppet: http://puppet.com/  
Packer: https://www.packer.io/
And the required Ruby Gems (including Nokogiri and Librarian-puppet)

### On Ubuntu these commands should get you up and running (Note: Windows bases also require Packer)
```bash
curl -o vagrant.deb https://releases.hashicorp.com/vagrant/1.8.4/vagrant_1.8.4_x86_64.deb
sudo dpkg -i vagrant.deb
sudo apt-get install ruby-dev zlib1g-dev liblzma-dev build-essential patch virtualbox
gem install bundle
```

Copy SecGen to a directory of your choosing, such as /home/user/bin/SecGen, then:
```bash
cd /home/user/bin/SecGen
bundle install
```

## Usage
Basic usage:
```bash
ruby secgen.rb run
```
This will use the default scenario to randomly generate VM(s).

SecGen accepts arguments to change the way that it behaves, the currently implemented arguments are:

```bash
   ruby secgen.rb [--options] <command>

   OPTIONS:
   --scenario [xml file], -s [xml file]: set the scenario to use
              (defaults to scenarios/default_scenario.xml)
   --project [output dir], -p [output dir]: directory for the generated project
              (output will default to projects/SecGen_DATEandTIME)
   --help, -h: shows this usage information

   COMMANDS:
   run, r: builds project and then builds the VMs
   build-project, p: builds project (vagrant and puppet config), but does not build VMs
   build-vms, v: builds VMs from a previously generated project
              (use in combination with --project [dir])

```

## Scenarios
SecGen generates VMs based on a scenario specification, which describes the constraints and properties of the VMs to be created.

### Using existing scenarios
Existing scenarios make SecGen's barrier for entry low: when invoking SecGen, a scenario can be specified as a command argument, and SecGen will then read the appropriate scenario definition and go about randomisation and VM generation. This removes the requirement for end users of the framework to understand SecGen's configuration specification.

Scenarios can be found in the scenarios/ directory. For example, to spin up a VM that has any random vulnerability:
```bash
   ruby secgen.rb --scenario scenarios/simple_examples/simple_any_random_vulnerability.xml run
```

### Defining new scenarios
Writing your own scenarios enables you to define a VM or set of VMs with a configuration as specific or general as desired.

SecGen's scenario specification is a powerful interface for specifying the constraints of the vulnerable systems to generate. Scenarios are defined in XML configuration files that specify systems in terms of a base, services/utilities, vulnerabilities, and networks.
- system: a VM
- base: a SecGen module that defines the OS platform (VM template) used to build the VM
- vulnerability: a SecGen module that adds an insecure, hackable, state (including realistic software vulnerabilities known to be in the wild or fabricated hacking challenges)
- service: a SecGen module that adds a (relatively secure) network service
- utility: a SecGen module that adds (relatively secure) software or configuration changes
- network: a virtual network card
 
The selection logic for choosing the modules to fulfill the specified constraints can filter on any of the attributes in each module's secgen_metadata.xml file (for example, difficulty level and/or CVE), and any ambiguity results in a random selection from the remaining matching options (for example, any vulnerability matching a specified difficulty level). 

For example, scenarios/simple_examples/simple_any_random_vulnerability.xml specifies one system with a Debian Linux base, and a vulnerability. In this case the base module is specified by module name, so this selection is predefined (there is only one possible module that matches), and the vulnerability is randomly selected from the entire set of vulnerabilities because no attribute filters are specified, which could have limited down the potential matches.

```xml
<?xml version="1.0"?>

<scenario xmlns="http://www.github/cliffe/SecGen/scenario"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.github/cliffe/SecGen/scenario">

  <system>
    <system_name>random_server</system_name>
    <base module_path="modules/bases/debian_puppet_32"/>
    <vulnerability />
  </system>
</scenario>
```

Note that the filters specified are [regular expression (regexp)](https://en.wikipedia.org/wiki/Regular_expression) matches. For example, here the module_path is any that matches anything followed by "distcc":
```xml
<?xml version="1.0"?>

<scenario xmlns="http://www.github/cliffe/SecGen/scenario"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://www.github/cliffe/SecGen/scenario">

  <system>
    <system_name>distcc_server</system_name>
    <base platform="linux"/>

    <vulnerability module_path=".*distcc" />

    <network type="private_network" range="dhcp" />
  </system>

</scenario>
```

Here scenarios/default_scenario.xml defines a scenario with a remotely exploitable vulnerability that grants access to a user account, and a locally exploitable root-level privilege escalation vulnerability. 

```xml
<?xml version="1.0"?>

<scenario xmlns="http://www.github/cliffe/SecGen/scenario"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://www.github/cliffe/SecGen/scenario">

  <!-- an example remote storage system, with a remotely exploitable vulnerability that can then be escalated to root -->
  <system>
    <system_name>storage_server</system_name>
    <base platform="linux"/>

    <vulnerability privilege="user" access="remote" />
    <vulnerability privilege="root" access="local" />

    <service/>

    <network type="private_network" range="dhcp"/>
  </system>
</scenario>

```
Note that with the exception of \<system_name>, all of the XML elements within \<system> will resolve to the addition of a SecGen module (a single module, plus any dependencies). The attributes specified filter down the set of modules to randomly select from. For example, the network card is selected from the available SecGen network card modules that are private_networks with dhcp.

## Modules
SecGen is designed to be easily extendable with modules that define vulnerabilities and other kinds of software, configuration, and content changes. 

As stated above, the types of modules supported in SecGen are:
 - base: a SecGen module that defines the OS platform (VM template) used to build the VM
 - vulnerability: a SecGen module that adds an insecure, hackable, state (including realistic software vulnerabilities known to be in the wild or fabricated hacking challenges)
 - service: a SecGen module that adds a (relatively secure) network service
 - utility: a SecGen module that adds (relatively secure) software or configuration changes
 - network: a virtual network card

Each vulnerability module is contained within the modules/vulnerabilies directory tree, which is organised to match the Metasploit Framework (MSF) modules directory structure. For example, the distcc_exec vulnerability module is contained within: modules/vulnerabilities/unix/misc/distcc_exec/. 

The root of the module directory always contains a secgen_metadata.xml file and also contains puppet files, which are used to make a system vulnerable.

### secgen_metadata.xml
The secgen_metadata.xml file defines the attributes of the module. In the case of vulnerability modules, this file contains information about the vulnerability, including CVE, privilege level the successful attacker gains, access level required in order to attack (remote vs local), metasploit module that can be used to exploit the vulnerability, CVSS score and vector string, difficulty level, and description. 

This information is used to filter module selection for scenarios, and also used to specify modules that conflict with each other or to satisfy dependencies between modules.

Example:
```xml
<?xml version="1.0"?>

<vulnerability xmlns="http://www.github/cliffe/SecGen/vulnerability"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xsi:schemaLocation="http://www.github/cliffe/SecGen/vulnerability">
  <name>DistCC Daemon Command Execution</name>
  <author>Lewis Ardern</author>
  <module_license>MIT</module_license>
  <description>Distcc has a documented security weakness that enables remote code execution.</description>

  <type>distcc</type>
  <privilege>user</privilege>
  <access>remote</access>
  <platform>unix</platform>

  <!--optional vulnerability details-->
  <difficulty>medium</difficulty>
  <cve>CVE-2004-2687</cve>
  <cvss_base_score>9.3</cvss_base_score>
  <cvss_vector>AV:N/AC:M/Au:N/C:C/I:C/A:C</cvss_vector>
  <reference>https://www.rapid7.com/db/modules/exploit/unix/misc/distcc_exec</reference>
  <reference>OSVDB-13378</reference>
  <software_name>distcc</software_name>
  <software_license>GPLv2</software_license>

  <!--optional hints-->
  <msf_module>exploit/unix/misc/distcc_exec</msf_module>
  <hint>On a non-standard port</hint>
  <solution>Distcc is vulnerable, and on a high port number.</solution>

  <!--Cannot co-exist with other installations-->
  <conflict>
    <software_name>distcc</software_name>
  </conflict>
</vulnerability>
```

#### name
The name of the module, with spaces and Title Caps.

#### author
Repeated one or more times for authors of the SecGen module and to acknowledge any authors of adapted Puppet modules from PuppetForge.

#### module_license MIT|Apache v2
The free and open source license the module is released under.

#### description
A description of the module and what it does.

#### type
A general category, in terms of the network protocol used (for example, ftp) if relevant.

#### privilege user|root
The level of privilege a successful attacker ends up with when exploitation is successful. User account, or root level access to the VM. As other challenges are added, the possible values will need to include database and information leaks.

#### access remote|local
The level of access the attacker needs to carry out the attack. Local access, such as an existing shell or user account, or remote, such as a vulnerable network service.

#### platform unix|linux
What OS(s) the module is compatible with.

#### difficulty (optional) low|medium|high
How hard the challenge is.

#### cve (optional)
For real vulnerabilies, the CVE where available.

#### cvss_base_score (optional)
The CVSS v2 Base Score. The score as [calculated based on the CVSS vector](https://nvd.nist.gov/cvss/v2-calculator?).

#### cvss_vector (optional)
The CVSS v2 vector string, for example: 'AV:L/AC:H/Au:N/C:N/I:P/A:C'

Access Vector (AV): L = Local access, A = adjacent access, N = network access  
Access Complexity (AC): H = High, M = Medium, L = Low  
Authentication (Au): N = None required, S = Single instance, M = Multi instance  
Confidentiality Impact (C): N = None, P = Partial, C = Complete  
Integrity Impact (I): N = None, P = Partial, C = Complete  
Availability Impact: N = None, P = Partial, C = Complete  

[NIST provide a handy online tool.](https://nvd.nist.gov/cvss/v2-calculator?)

#### reference (optional)
Repeated for URLs with further information about the vulnerability, exploit, and software. For example, information about the vulnerability, links to exploits, and so on.

#### software_name (optional)
Package name of software installed by the puppet modules (as named in software repositories).

#### software_license (optional) MIT|Apache v2
The license of the installed/bundled software.

#### msf_module (optional)
A Metasploit module (if one exists) to compromise the vulnerability. For example, "exploit/unix/misc/distcc_exec".

#### hint (optional)
A hint to direct the attacker in the right direction.

#### solution (optional)
A solution to the challenge.

#### conflict (optional)
A module may conflict with other modules based on matches to attributes or module_path. Each conflict can have multiple conditions which must all be met for this to be considered a conflict. 

For example, to conflict with modules that provide a web server and install apache:
```xml
<conflict>
  <type>httpd</type>
  <software_name>apache</software_name>
<conflict>
```
That example would not conflict with other web servers that don't include "apache" in the software_name.

If multiple \<conflict> elements are specified, it only takes any one conflict to prevent a conflicting module to be selected.

When creating modules, __conflicts should be avoided wherever possible__, as they can significantly reduce the randomisation options for complex scenarios, and can cause complications in the resolution of scenarios (which is currently solved via bruteforce).

#### requires (optional)
A module can include \<requires> tags to require other modules that satisfy a set of conditions are also added to the scenario. When selecting a module, each of these dependencies is resolved by checking if a module has already been selected that satisfies the condition, in which case nothing happens, otherwise a module that satisfies all the conditions is randomly selected and added to the scenario. This is recursive so a module can require modules that require modules. 

When conflicts occur (say for example, a previously selected module conflicts with all the valid options for resolving a dependency) the scenario is regenerated. This bruteforce approach is fairly effective, but \<conflict> tags should be avoided wherever possible because they add complexity and reduce randomisation possibilities.

A module can have multiple \<requires>, each of which will ensure a single module fulfills all of the conditions, which are regexp matches against attributes.

For example, for a module that needs to have a repo refresh (apt-get update) first:
```xml
  <requires>
    <type>update</type>
  </requires>
```
Or for a module that requires apache be installed by another module (rather than the module itself installing apache, alternatively):
```xml
<requires>
    <type>httpd</type>
    <software_name>apache</software_name>
  </requires>
```

In this (silly) example, writable_shadow requires apache which requires update:
![recursive_dependencies](https://cloud.githubusercontent.com/assets/670192/17168086/4a08e162-53d8-11e6-83a0-0892d4fc2d68.png)

In another silly example, here apache requires ftp, but all ftp modules conflict with writable_shadow: 
![recursive_dependency_resolution](https://cloud.githubusercontent.com/assets/670192/17168883/b18ff362-53dc-11e6-8288-fa49a5f3459e.png)

### Puppet files
Each vulnerability, service, and utility module contains Puppet files which are used to provision the software onto the VMs.

The module directory contains
 - a Puppet module
 - Puppet entry point (same file name as the module directory, .pp)

This example should help illustrate. Distcc has a documented security weakness that enables remote code execution. The below example comes from modules/vulnerabilities/misc/distcc_exec.

A manifest/ directory contains the Puppet files for a distcc_exec Puppet class.

As is convention, one file for Installation:
````
class distcc_exec::install{
  package { 'distcc':
    ensure => installed
  }
}
````
One file for configuration (plus a template file):
````
class distcc_exec::config{
  file { '/etc/default/distcc':
    require => Package['distcc'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0777',
    content  => template('distcc_exec/distcc.erb')
  }
}
````
One file for ensuring the service starts:
````
class distcc_exec::service{
  service { 'distcc':
    ensure => running
  }
}
````
So far this is all typical Puppet.

Finally, we add a module entry point, with the same name as the directory .pp:
````
include distcc_exec::install
include distcc_exec::config
include distcc_exec::service
````

To learn more about Puppet and understand the how to write modules check out the SecGen Wiki and also http://puppetlabs.com/

## Output
By default output is to projects/SecGen_[CurrentTime]/

The project output includes:
 - A vagrant configuration for spinning up the boxes.
 - A directory containing all the required puppet modules. A Librarian-Puppet file is created to manage modules, and some required modules may be obtained via PuppetForge, and therefore an Internet connection is required when building the project.
 - A de-randomised scenario XML file. This is a XML scenario file that can be used to replay these systems. Any randomisation that has been applied should be un-randomised in this output (compared to the original scenario file). This can also be used later for grading, scoring, or giving hints. 

The VM building process takes the project output and builds the VMs.

## Roadmap
### Parameterisation of vulnerabilities
A new feature in development, is the parameterisation of vulnerabilities and services, so that each vulnerability can also be configured various (and randomisable) ways. This enables a number of important enhancements, such as: 
- the ability to feed content into hosted websites (independant of the vulnerabilities or even CMS in use)
- specify or randomise aspects of a challenge, such as files or users
- feed randomly generated CTF flags into hacking challenges

## Contributing
We encourage contributions to the project, please see the wiki for guidance on how to contribute.

Briefly, please fork from github.com/cliffe/SecGen, create a branch, make and commit your changes, then create a pull request.

The SecGen team have prepared a VM located at: https://drive.google.com/open?id=0B6fyxD2qGmUIaXpDZElKczdQYW8 to make 
contributing for SecGen easier, it includes Ruby, git and RubyMine pre-installed, however, some tweaking may be required.
