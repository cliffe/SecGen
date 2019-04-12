# Defining new SecGen scenarios
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

## Advanced scenarios: parameterisation
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

## Advanced scenarios: Ensuring modules selected are unique

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

## Advanced scenarios: Using datastores (variables) to hold values for reuse

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
