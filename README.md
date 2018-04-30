# Security Scenario Generator (SecGen)

## Summary
SecGen creates vulnerable virtual machines so students can learn security penetration testing techniques. 

Boxes like Metasploitable2 are always the same, this project uses Vagrant, Puppet, and Ruby to create randomly vulnerable virtual machines that can be used for learning or for hosting CTF events. 

[The latest version is available at: http://github.com/cliffe/SecGen/](http://github.com/cliffe/SecGen/)

## Introduction
Computer security students benefit from engaging in hacking challenges. Practical lab work and pre-configured hacking challenges are common practice both in security education and also as a pastime for security-minded individuals. Competitive hacking challenges, such as capture the flag (CTF) competitions have become a mainstay at industry conferences and are the focus of large online communities. Virtual machines (VMs) provide an effective way of sharing targets for hacking, and can be designed in order to test the skills of the attacker. Websites such as Vulnhub host pre-configured hacking challenge VMs and are a valuable resource for those learning and advancing their skills in computer security. However, developing these hacking challenges is time consuming, and once created, essentially static. That is, once the challenge has been "solved" there is no remaining challenge for the student, and if the challenge is created for a competition or assessment, the challenge cannot be reused without risking plagiarism, and collusion. 

Security Scenario Generator (SecGen) generates randomised vulnerable systems. VMs are created based on a scenario specification, which describes the constraints and properties of the VMs to be created. For example, a scenario could specify the creation of a system with a remotely exploitable vulnerability that would result in user-level compromise, and a locally exploitable flaw that would result in root-level compromise. This would require the attacker to discover and exploit both randomly selected vulnerabilities in order to obtain root access to the system. Alternatively, the scenario that is defined can be more specific, specifying certain kinds of services (such as FTP or SMB) or even exact vulnerabilities (by CVE).

SecGen is a Ruby application, with an XML configuration language. SecGen reads its configuration, including the available vulnerabilities, services, networks, users, and content, reads the definition of the requested scenario, applies logic for randomising the scenario, and leverages Puppet and Vagrant to provision the required VMs.

## License
SecGen is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

SecGen contains modules, which install various software packages. Each SecGen module may contain or remotely source software, and each module defines its own license in the accompanying secgen_metadata.xml file.

## Installation
SecGen is developed and tested on Ubuntu Linux. In theory, SecGen should run on Mac or Windows, if you have all the required software installed.

You will need to install the following:
- Ruby (development): https://www.ruby-lang.org/en/
- Vagrant: http://www.vagrantup.com/
- Virtual Box: https://www.virtualbox.org/
- Puppet: http://puppet.com/
- Packer: https://www.packer.io/
- ImageMagick: https://www.imagemagick.org/
- And the required Ruby Gems (including Nokogiri and Librarian-puppet)

### On Ubuntu these commands will get you up and running
Install all the required packages:
```bash
# install a recent version of vagrant
wget https://releases.hashicorp.com/vagrant/1.9.8/vagrant_1.9.8_x86_64.deb
sudo apt install ./vagrant_1.9.8_x86_64.deb
# install other required packages via repos
sudo apt-get install ruby-dev zlib1g-dev liblzma-dev build-essential patch virtualbox ruby-bundler imagemagick libmagickwand-dev exiftool libpq-dev libcurl4-openssl-dev libxml2-dev
```

Copy SecGen to a directory of your choosing, such as */home/user/bin/SecGen*

Then install gems:
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
![gify goodness](lib/resources/images/readme_gifs/secgen_default_scenario_run.gif  "SecGen randomising a vulnerable VM -- part 1, randomisation")
![gify goodness](lib/resources/images/readme_gifs/secgen_default_scenario_run_vm.gif  "SecGen randomising a vulnerable VM -- part 2, provisioning VMs")

SecGen accepts arguments to change the way that it behaves, the currently implemented arguments are:

```bash
   ruby secgen.rb [--options] <command>

   OPTIONS:
   --scenario [xml file], -s [xml file]: set the scenario to use
              (defaults to scenarios/default_scenario.xml)
   --project [output dir], -p [output dir]: directory for the generated project
              (output will default to projects/SecGen_DATEandTIME)
   --shutdown: Shutdown vms after provisioning
   --network-ranges: Override network ranges within the scenario, use a comma-separated list
   --forensic-image-type [image type]: Forensic image format of generated image (raw, ewf)
   --read-options [conf path]: Reads options stored in file as arguments (see example.conf)
   --help, -h: Shows this usage information

   VIRTUALBOX OPTIONS:
   --gui-output', '-g': gui output
   --nopae: disable PAE support
   --hwvirtex: enable HW virtex support
   --vtxvpid: enable VTX support

   OVIRT OPTIONS:
   --ovirtuser [ovirt_username]         
   --ovirtpass [ovirt_password]         
   --ovirt-url [ovirt_api_url]          
   --ovirt-cluster [ovirt_cluster]      
   --ovirt-network [ovirt_network_name] 
   
   COMMANDS:
   run, r: builds project and then builds the VMs
   build-project, p: builds project (vagrant and puppet config), but does not build VMs
   build-vms, v: builds VMs from a previously generated project
              (use in combination with --project [dir])
   create-forensic-image [/project/dir], v [project #]: Builds forensic images from a previously generated project
                         (can be used in combination with --project [dir])
   list-scenarios: Lists all scenarios that can be used with the --scenario option
   list-projects: Lists all projects that can be used with the --project option
   delete-all-projects: Deletes all current projects in the projects directory

```

## Scenarios
SecGen generates VMs based on a scenario specification, which describes the constraints and properties of the VMs to be created.

### Using existing scenarios
Existing scenarios make SecGen's barrier for entry low: when invoking SecGen, a scenario can be specified as a command argument, and SecGen will then read the appropriate scenario definition and go about randomisation and VM generation. This removes the requirement for end users of the framework to understand SecGen's configuration specification.

Scenarios can be found in the scenarios/ directory. For example, to spin up a VM that has a random remotly exploitable vulnerability that results in user-level compromise:
```bash
   ruby secgen.rb --scenario scenarios/examples/remotely_exploitable_user_vulnerability.xml run
```
![gify goodness](lib/resources/images/readme_gifs/secgen_random_example.gif  "Remotly exploitable example where an attacker ends up with user-level access")

#### VMs for a security audit of an organisation
To generate a set of VMs for a randomly generated fictional organisation, with a desktop system, webserver, and intranet server:
```bash
   ruby secgen.rb --scenario scenarios/security_audit/team_project_scenario.xml run
```
Note that the intranet server has a security remit, with instructions on performing a security audit of these systems. The desktop system can access the intranet to access the remit, but the attacker VM (for example, Kali) can be connected to the NIC only shared by the Web server to simulate the need to pivot attacks through the Web server, as they can't connect to the intranet system directly. The "marking guide" is in the form of the output scenario.xml in the project directory, which provides the details of the systems generated.

#### VMs for a CTF event
To generate a set of VMs for a CTF competition:
```bash
   ruby secgen.rb --scenario scenarios/ctf/flawed_fortress_1.xml run
```
Note the flags and hints are stored in marker.xml

We also have developed and released [a frontend web interface for hosting CTF events](https://github.com/cliffe/flawed_fortress-secgen_ctf_frontend) a frontend web interface for hosting CTF events.

### Defining new scenarios
Writing your own scenarios enables you to define a VM or set of VMs with a configuration as specific or general as desired.

SecGen's scenario specification is a powerful interface for specifying the constraints of the vulnerable systems to generate. Scenarios are defined in XML configuration files that specify systems in terms of a base, services/utilities, vulnerabilities, and networks.
- system: a VM
- base: a SecGen module that defines the OS platform (VM template) used to build the VM
- vulnerability: a SecGen module that adds an insecure, hackable, state (including realistic software vulnerabilities known to be in the wild or fabricated hacking challenges)
- service: a SecGen module that adds a (relatively secure) network service
- utility: a SecGen module that adds (relatively secure) software or configuration changes
- network: a virtual network card
- generator: generates output, such as random text
- encoder: receives input, such as random text, performs operations on that to produce output (such as, encoding/encryption/selection)

 
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

    <vulnerability privilege="user_rwx" access="remote" />
    <vulnerability privilege="root_rwx" access="local" />

    <service/>

    <network type="private_network" range="dhcp"/>
  </system>
</scenario>

```
Note that with the exception of \<system_name>, all of the XML elements within \<system> will resolve to the addition of a SecGen module (a single module, plus any dependencies and default values). The attributes specified filter down the set of modules to randomly select from. For example, the network card is selected from the available SecGen network card modules that are private_networks with dhcp.

#### Advanced scenarios: parameterisation
Some modules can be fed input. For example, a vulnerability can be fed information to leak as output. In this case, a NFS share will host a publicly exported file containing the leaked text:
```xml
<?xml version="1.0"?>

<scenario xmlns="http://www.github/cliffe/SecGen/scenario"
	   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	   xsi:schemaLocation="http://www.github/cliffe/SecGen/scenario">

	<system>
		<system_name>file_server</system_name>
		<base platform="linux"/>

		<vulnerability module_path=".*nfs_overshare">
			<input into="strings_to_leak">
				<value>Leak this text, and a randomly generated flag</value>
				<generator type="flag_generator"/>
			</input>
		</vulnerability>

		<network type="private_network" range="dhcp"/>
	</system>

</scenario>
```

Encoders, generators, and literal values can be nested.

SecGen module parameters are analogous to [named and (always) optional parameters](https://en.wikipedia.org/wiki/Named_parameter) (for example, [as in C#](https://msdn.microsoft.com/en-us/library/dd264739.aspx)).

The above can be illustrated in pseudo code:
```C
// This is just some pseudo code to help explain
vulnerabilty_nfs_overshare(strings_to_leak: ["Leak this text, and a randomly generated flag", generator_flag()]);
```

Another example, as above, but the message and flag are first base64 encoded:
```xml
<?xml version="1.0"?>

<scenario xmlns="http://www.github/cliffe/SecGen/scenario"
	   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	   xsi:schemaLocation="http://www.github/cliffe/SecGen/scenario">

	<system>
		<system_name>file_server</system_name>
		<base platform="linux"/>

		<vulnerability module_path=".*nfs_overshare">
			<input into="strings_to_leak">
				<encoder name="BASE64 Encoder">
					<input into="strings_to_encode">
						<value>Leak this text, and a randomly generated flag</value>
						<generator type="flag_generator"/>
					</input>
				</encoder>
			</input>
		</vulnerability>

		<network type="private_network" range="dhcp"/>
	</system>

</scenario>
```

Generators and encoders will always produce/return an (unnamed) array of Strings, which can be directed to input parameters for other modules (by parameter name into modules they are nested under, as illustrated above). 

All encoders will accept and process the "strings_to_encode" parameter, so it's safe to pass input into any randomly selected encoder (though you may want to filter to reversible encoders for a decoding challenge, as shown below). It's possible to direct the output from multiple modules to input to the same module parameter. For example: 

```xml
<?xml version="1.0"?>

<scenario xmlns="http://www.github/cliffe/SecGen/scenario"
	   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	   xsi:schemaLocation="http://www.github/cliffe/SecGen/scenario">

	<system>
		<system_name>file_server</system_name>
		<base platform="linux"/>

		<vulnerability module_path=".*nfs_overshare">
			<input into="strings_to_leak">
				<!--output from this encoder...-->
				<encoder type="ascii_reversible">
					<input into="strings_to_encode">
						<generator type="flag_generator" />
					</input>
				</encoder>
				<!--and from this generator:-->
				<generator type="flag_generator" />
            </input>
        </vulnerability>

		<network type="private_network" range="dhcp"/>
	</system>

</scenario>

```

In this case each of the nested inputs to that same parameter are concatenated into the same array of strings. This is roughly analogous to:
```C
// This is just some pseudo code to help explain
// (C#-like methods with named arguments)
vulnerability_nfs_share_leak(strings_to_leak: encoder_selected_ascii_reversible(strings_to_encode: encoder_flag_generator()) CONCATENATE_WITH encoder_flag_generator());
```

You might want to write to any module that has a particular parameter: for example, a vulnerability that has a "strings_to_leak" parameter, meaning a vulnerability that when exploited reveals strings to the attacker:
 ```xml
 <?xml version="1.0"?>
 
 <scenario xmlns="http://www.github/cliffe/SecGen/scenario"
 	   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 	   xsi:schemaLocation="http://www.github/cliffe/SecGen/scenario">
 
 	<system>
 		<system_name>file_server</system_name>
 		<base platform="linux"/>
		<!--this line selects a vulnerability that can leak strings:-->
 		<vulnerability read_fact="strings_to_leak">
 			<input into="strings_to_leak">
 				<encoder type="ascii_reversible">
 					<input into="strings_to_encode">
 						<generator type="flag_generator" />
 					</input>
 				</encoder>
 				<generator type="flag_generator" />
             </input>
         </vulnerability>
 
 		<network type="private_network" range="dhcp"/>
 	</system>
 
 </scenario>
 
 ```

The parameters that each module accepts is listed in each module's secgen_metadata.xml file, as described below.

#### Advanced scenarios: Ensuring modules selected are unique

If you want to use a bunch of modules to generate input for another module's parameters, you can specify a (named) list to exclude modules from being selected more than once.
```xml
[snip]
		<vulnerability name="NFS Share Leak">
			<input into="strings_to_leak" unique_module_list="unique_encoders">
				<encoder type="ascii_reversible">
					<input into="strings_to_encode">
						<generator type="flag_generator" />
					</input>
				</encoder>
				<encoder type="alpha_reversible">
					<input into="strings_to_encode">
						<generator type="flag_generator" />
					</input>
				</encoder>
				<encoder type="alpha_reversible">
					<input into="strings_to_encode">
						<generator type="flag_generator" />
					</input>
				</encoder>
			</input>
		</vulnerability>
[snip]
```
The "unique_module_list='unique_encoders'" ensures that the encoders selected will not be repeated.

#### Advanced scenarios: Using datastores (variables) to hold values for reuse

Datastores are essentially variables that you can write to and then reuse. This is *similar* to "variables" in other languages. However, a datastore always holds an array of strings, and writing to the datastore concatenates to the array of strings.

You can use datastores, to capture values. Here we generate two flags and store them in the same datastore:

```xml
		<input into_datastore="flags">
			<generator type="flag_generator" />
			<generator type="flag_generator" />
		</input>
```
Here we generate two flags and store them in separate datastores.
```xml
		<input into_datastore="flag1">
			<generator type="flag_generator" />
		</input>
		<input into_datastore="flag2">
			<generator type="flag_generator" />
		</input>
```
We can then pass the datastore (flag2) into a module parameter, and capture the output into a separate datastore (encoded_flag):
```xml

		<input into_datastore="encoded_flag">
			<encoder type="ascii_reversible">
				<input into="strings_to_encode">
					<datastore>flag2</datastore>
				</input>
			</encoder>
		</input>
```
And leak the result via a vulnerability:
```xml
		<!--  vulnerability_nfs_share(strings_to_leak: encoded_flag CONCAT flag1)   -->
		<vulnerability name="NFS Share Leak">
			<input into="strings_to_leak" unique_module_list="unique_encoders">
				<datastore>encoded_flag</datastore>
				<datastore>flag1</datastore>
			</input>
		</vulnerability>
```

You can use datastores to store generate information for complex scenarios, such as the organisation's name, employees, and so on. Then feed that information through to websites, and services, user accounts, and so on. For a detailed example, see the team project security audit scenario:

```scenarios/security_audit/team_project_scenario.xml```

It is also possible to iterate through a datastore, and feed each value into separate modules. This is illustrated in:
```scenarios/examples/datastore_examples/iteration_and_element_access.xml```

Some generators generate structured content in JSON format, for example the organisation type. It is possible to access a particular element of structured data from a datastore with the access_json using the ruby hash lookup format. See the example scenario:
```scenarios/examples/datastore_examples/json_selection_example.xml```

Some scenarios require VMs IP addresses to be used as parameters for other modules in the scenario. If this is the case, you should use the 'IP_addresses' datastore to store the IPs for all VMs in the scenario and use the access functionality to pass them into network modules.For example:
```scenarios/examples/datastore_examples/network_ip_datastore_example.xml```  

## Modules
SecGen is designed to be easily extendable with modules that define vulnerabilities and other kinds of software, configuration, and content changes. 

As stated above, the types of modules supported in SecGen are:
 - base: a SecGen module that defines the OS platform (VM template) used to build the VM
 - vulnerability: a SecGen module that adds an insecure, hackable, state (including realistic software vulnerabilities known to be in the wild or fabricated hacking challenges)
 - service: a SecGen module that adds a (relatively secure) network service
 - utility: a SecGen module that adds (relatively secure) software or configuration changes
 - network: a virtual network card
 - generator: generates output, such as random text
 - encoder: receives input, such as text, performs operations on that to produce output (such as, encoding/encryption/selection)

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
  <privilege>user_rwx</privilege>
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

#### privilege info_leak | root_r | root_rw | root_rwx | user_r| user_rw | user_rwx
The level of privilege a successful attacker ends up with when exploitation is successful.

Information leakage: info_leak (e.g. nfs/nfs_overshare)
Shell access: root_rwx, user_rwx (e.g. local/setuid_nmap, smb/samba_symlink_traversal)
Read and write access: root_rw, user_rw (e.g. access_control_misconfigurations/uid_vi_root, smb/samba_public_writable_share)
Read access: root_r (e.g. access_control_misconfigurations/uid_less_root)

As other challenges are added database leaks will be added as a privilege level option.

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

#### read_fact (optional)

A module can declare that it uses input it receives. The most common input parameters are "strings_to_encode", and "strings_to_leak". read_fact can also be repeated for any other configuration parameters for the module.

#### default_input (optional)

A module definition can specify default inputs to be used when none is specified via the scenario. This means that if a vulnerability module is selected without input (for example, randomly selected from all vulnerabilies), input for the parameters for that module can be generated automatically.

For example:

secgen_metadata.xml:
```xml
<read_fact>strings_to_leak</read_fact>

<!--if an input is not specified in the scenario-->
<default_input into="strings_to_leak">
  <value>Plain text from the metadata default, destined for strings_to_leak...</value>
</default_input>
<default_input into="some_random_setting">
  <value>true</value>
</default_input>
```

Note that the scenario could select on and pass through specific parameters:

scenario.xml:
```xml
<vulnerability read_fact="strings_to_leak">
  <input into="strings_to_leak">
    <value>LEAK THIS!</value>
  </input>
</vulnerability>
```
In the above case the "some_random_setting" parameter would take on it's default value (["true"]), and the strings leaked would be the value coming from the scenario (["LEAK THIS!"]).

Parameter values can be randomly selected between using the random selection encoder module. For example:

secgen_metadata.xml:
```xml
<default_input into="some_random_setting">
  <encoder name="Random String Selector">
    <value>true</value>
    <value>false</value>
  </encoder>
</default_input>
```
As a result, any time the module is used it would randomly be configured, unless specifically specified in the scenario. 

The default inputs can also be constructed using complex nested generators and encoders:

secgen_metadata.xml:
```xml
<read_fact>strings_to_leak</read_fact>

<!--if an input is not specified in the scenario-->
<default_input into="strings_to_leak">
  <value>Plain text from the metadata default, destined for strings_to_leak...</value>
  <encoder type="string_encoder">
    <input into="strings_to_encode">
      <!--encode the following strings-->
      <value>Encoded text from the metadata default, destined for strings_to_leak...</value>
      <value>More encoded text from the metadata default, destined for strings_to_leak...</value>
      <generator module_path=".*random.*"/>
    </input>
  </encoder>
</default_input>
```

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

### local/secgen_local.rb

Encoders and generators have code that is evaluated at project build time, such as encoding text, and generating flags and other content. In each case, this is a ruby script located within the module directory in local/secgen_local.rb. Although normally called by SecGen, secgen_local.rb scripts can be executed directly, and accept all the parameter inputs as command line arguments, and returns the output in JSON format to stdout. Other human readable output is written to stderr.

```bash
#ruby modules/encoders/string/base64/secgen_local/local.rb --strings_to_encode "encode this" --strings_to_encode "and this" 
BASE64 Encoder
 Encoding '["encode this", "and this"]'
 Encoded: ["ZW5jb2RlIHRoaXM=", "YW5kIHRoaXM="]
["ZW5jb2RlIHRoaXM=","YW5kIHRoaXM="]
```
![gify goodness](lib/resources/images/readme_gifs/base64_encoder_run.gif  "secgen_local.rb scripts can be executed directly")
![gify goodness](lib/resources/images/readme_gifs/base64_encoder_code.gif  "Coding a generator or encoder is easy!")

## SecGen project output
By default output is to projects/SecGen_[CurrentTime]/

The project output includes:
 - A vagrant configuration for spinning up the boxes.
 - A directory containing all the required puppet modules for the above. A Librarian-Puppet file is created to manage modules, and some required modules may be obtained via PuppetForge, and therefore an Internet connection is required when building the project.
 - A de-randomised scenario XML file. Using SecGen you can use this scenario.xml file to recreate the above Vagrant config and puppet files. Any randomisation that has been applied should be un-randomised in this output (compared to the original scenario file). This file contains all the details of the systems created, and can also be used later for grading, scoring, or giving hints. 
 - A marker.xml file useful for CTF events, containing all the flags along with multiple hints per flag. This can be used to configure the CTF frontend.

If you start SecGen with the "build-project" (or "p") command it creates the above files and then stops. The "run" (or "r") command creates the project files then uses Vagrant to build the VM(s).

It is possible to copy the project directory to any compatible system with Vagrant, and simply run "vagrant up" to create the VMs.

The default root password for the base-boxes is 'puppet', but this may be modified by SecGen depending on the scenario used.

## Roadmap
- **More modules!** Including more CTF-style modules.
- Windows baseboxes and vulnerabilities.
- Output (randomised) security labs with worksheets.
- Cloud deployment.
- Further gamification and immersive scenarios.

## Acknowledgments
*Development team:*
- Dr Z. Cliffe Schreuders http://z.cliffe.schreuders.org
- Tom Shaw
- Jason Keighley
- Lewis Ardern -- author of the first proof-of-concept release of SecGen
- Connor Wilson

Many thanks to everyone who has contributed to the project. The above list is not complete or exhaustive, please refer to the [GitHub history](https://github.com/cliffe/SecGen/graphs/contributors).

This project is supported by a Higher Education Academy (HEA) learning and teaching in cyber security grant (2015-2017).

## Contributing
We encourage contributions to the project, please see the wiki for guidance on how to contribute.

Briefly, please fork from http://github.com/cliffe/SecGen/, create a branch, make and commit your changes, then create a pull request.

## Resources
Paper: [Z.C. Schreuders, T. Shaw, M. Shan-A-Khuda, G. Ravichandran, J. Keighley, M. Ordean, “Security Scenario Generator (SecGen): A Framework for Generating Randomly Vulnerable Rich-scenario VMs for Learning Computer Security and Hosting CTF Events,” USENIX Workshop on Advances in Security Education (ASE'17), Vancouver, BC, Canada. USENIX Association, 2017.](https://www.usenix.org/conference/ase17/workshop-program/presentation/schreuders) (This paper provides a good overview of SecGen.)

Paper: [Z.C. Schreuders, and L. Ardern, "Generating randomised virtualised scenarios for ethical hacking and computer security education: SecGen implementation and deployment," in The first UK Workshop on Cybersecurity Training & Education (Vibrant Workshop 2015) Liverpool, UK, 2015.](http://z.cliffe.schreuders.org/publications/VibrantWorkshop2015%20-%20Generating%20randomised%20virtualised%20scenarios%20for%20ethical%20hacking%20and%20computer%20security%20education%20%28SecGen%29.pdf) (This paper describes the first prototype.)

Podcast interview: [Purple Squad Security Episode 011 – Security Scenario Generator with Dr. Z. Cliffe Schreuders](https://purplesquadsec.com/podcast/episode-011-security-scenario-generator-dr-z-cliffe-schreuders/) 
