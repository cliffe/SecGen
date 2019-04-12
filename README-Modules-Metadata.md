## Modules
SecGen is designed to be easily extendable with modules that define vulnerabilities and other kinds of software, configuration, and content changes.

The types of modules supported in SecGen are:
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
