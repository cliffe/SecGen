#firewall

[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-firewall.png?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-firewall)

####Table of Contents

1. [Overview - What is the firewall module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with firewall](#setup)
    * [What firewall Affects](#what-firewall-affects)
    * [Setup Requirements](#setup-requirements)
    * [Beginning with firewall](#beginning-with-firewall)
    * [Upgrading](#upgrading)
4. [Usage - Configuration and customization options](#usage)
    * [Default rules - Setting up general configurations for all firewalls](#default-rules)
    * [Application-Specific Rules - Options for configuring and managing firewalls across applications](#application-specific-rules)
    * [Additional Uses for the Firewall Module](#other-rules)
5. [Reference - An under-the-hood peek at what the module is doing](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
    * [Tests - Testing your configuration](#tests)

## Overview

The firewall module lets you manage firewall rules with Puppet.

## Module Description

PuppetLabs' firewall module introduces the `firewall` resource, which is used to manage and configure firewall rules from within the Puppet DSL. This module offers support for iptables and ip6tables. The module also introduces the `firewallchain` resource, which allows you to manage chains or firewall lists and ebtables for bridging support. At the moment, only iptables and ip6tables chains are supported.

The firewall module acts on your running firewall, making immediate changes as the catalog executes. Defining default pre and post rules allows you to provide global defaults for your hosts before and after any custom rules. Defining `pre` and `post` rules is also necessary to help you avoid locking yourself out of your own boxes when Puppet runs.

## Setup

### What firewall Affects

* Every node running a firewall
* Firewall settings in your system
* Connection settings for managed nodes
* Unmanaged resources (get purged)


### Setup Requirements

Firewall uses Ruby-based providers, so you must enable [pluginsync](http://docs.puppetlabs.com/guides/plugins_in_modules.html#enabling-pluginsync).

### Beginning with firewall

In the following two sections, you create new classes and then create firewall rules related to those classes. These steps are optional but provide a framework for firewall rules, which is helpful if you’re just starting to create them.

If you already have rules in place, then you don’t need to do these two sections. However, be aware of the ordering of your firewall rules. The module will dynamically apply rules in the order they appear in the catalog, meaning a deny rule could be applied before the allow rules. This might mean the module hasn’t established some of the important connections, such as the connection to the Puppet master.

The following steps are designed to ensure that you keep your SSH and other connections, primarily your connection to your Puppet master. If you create the `pre` and `post` classes described in the first section, then you also need to create the rules described in the second section.

#### Create the `my_fw::pre` and `my_fw::post` Classes

This approach employs a whitelist setup, so you can define what rules you want and everything else is ignored rather than removed.

The code in this section does the following:

* The 'require' parameter in `firewall {}` ensures `my_fw::pre` is run before any other rules.  
* In the `my_fw::post` class declaration, the 'before' parameter ensures `my_fw::post` is run after any other rules.

Therefore, the run order is:

* The rules in `my_fw::pre`
* Your rules (defined in code)
* The rules in `my_fw::post`

The rules in the `pre` and `post` classes are fairly general. These two classes ensure that you retain connectivity and that you drop unmatched packets appropriately. The rules you define in your manifests are likely specific to the applications you run.

1.) Add the `pre` class to my_fw/manifests/pre.pp. Your pre.pp file should contain any default rules to be applied first. The rules in this class should be added in the order you want them to run.2. 
  ~~~puppet
  class my_fw::pre {
    Firewall {
      require => undef,
    }

    # Default firewall rules
    firewall { '000 accept all icmp':
      proto  => 'icmp',
      action => 'accept',
    }->
    firewall { '001 accept all to lo interface':
      proto   => 'all',
      iniface => 'lo',
      action  => 'accept',
    }->
    firewall { '002 reject local traffic not on loopback interface':
      iniface     => '! lo',
      proto       => 'all',
      destination => '127.0.0.1/8',
      action      => 'reject',
    }->
    firewall { '003 accept related established rules':
      proto  => 'all',
      state  => ['RELATED', 'ESTABLISHED'],
      action => 'accept',
    }
  }
  ~~~

  The rules in `pre` should allow basic networking (such as ICMP and TCP) and ensure that existing connections are not closed.

2.) Add the `post` class to my_fw/manifests/post.pp and include any default rules to be applied last.

  ~~~puppet
  class my_fw::post {
    firewall { '999 drop all':
      proto  => 'all',
      action => 'drop',
      before => undef,
    }
  }
  ~~~

Alternatively, the [firewallchain](#type-firewallchain) type can be used to set the default policy:

  ~~~puppet
  firewallchain { 'INPUT:filter:IPv4':
    ensure => present,
    policy => drop,
    before => undef,
  }
  ~~~

#### Create Firewall Rules

The rules you create here are helpful if you don’t have any existing rules; they help you order your firewall configurations so you don’t lock yourself out of your box.

Rules are persisted automatically between reboots, although there are known issues with ip6tables on older Debian/Ubuntu distributions. There are also known issues with ebtables.

1.) In site.pp or another top-scope file, add the following code to set up a metatype to purge unmanaged firewall resources. This will clear any existing rules and make sure that only rules defined in Puppet exist on the machine.

  ~~~puppet
  resources { 'firewall':
    purge => true,
  }
  ~~~

  To purge unmanaged firewall chains, also add:

  ~~~puppet
  resources { 'firewallchain':
    purge => true,
  }
  ~~~
  
  **Note** - If there are unmanaged rules in unmanaged chains, it will take two Puppet runs before the firewall chain is purged. This is different than the `purge` parameter available in `firewallchain`.

2.)  Use the following code to set up the default parameters for all of the firewall rules you will establish later. These defaults will ensure that the `pre` and `post` classes are run in the correct order to avoid locking you out of your box during the first Puppet run.

  ~~~puppet
  Firewall {
    before  => Class['my_fw::post'],
    require => Class['my_fw::pre'],
  }
  ~~~

3.) Then, declare the `my_fw::pre` and `my_fw::post` classes to satisfy dependencies. You can declare these classes using an External Node Classifier or the following code:

  ~~~puppet
  class { ['my_fw::pre', 'my_fw::post']: }
  ~~~

4.) Include the `firewall` class to ensure the correct packages are installed.

  ~~~puppet
  class { 'firewall': }
  ~~~

### Upgrading

Use these steps if you already have a version of the firewall module installed.

#### From version 0.2.0 and more recent

Upgrade the module with the puppet module tool as normal:

    puppet module upgrade puppetlabs/firewall

## Usage

There are two kinds of firewall rules you can use with firewall: default rules and application-specific rules. Default rules apply to general firewall settings, whereas application-specific rules manage firewall settings for a specific application, node, etc.

All rules employ a numbering system in the resource's title that is used for ordering. When titling your rules, make sure you prefix the rule with a number, for example, '000 accept all icmp requests'. _000_ runs first, _999_ runs last.

### Default Rules

You can place default rules in either `my_fw::pre` or `my_fw::post`, depending on when you would like them to run. Rules placed in the `pre` class will run first, and rules in the `post` class, last.

In iptables, the title of the rule is stored using the comment feature of the underlying firewall subsystem. Values must match '/^\d+[[:graph:][:space:]]+$/'.

#### Examples of Default Rules

Basic accept ICMP request example:

~~~puppet
firewall { '000 accept all icmp requests':
  proto  => 'icmp',
  action => 'accept',
}
~~~

Drop all:

~~~puppet
firewall { '999 drop all other requests':
  action => 'drop',
}
~~~

#### Example of an IPv6 rule

IPv6 rules can be specified using the _ip6tables_ provider:

~~~puppet
firewall { '006 Allow inbound SSH (v6)':
  dport     => 22,
  proto    => tcp,
  action   => accept,
  provider => 'ip6tables',
}
~~~

### Application-Specific Rules

Puppet doesn't care where you define rules, and this means that you can place
your firewall resources as close to the applications and services that you
manage as you wish. If you use the [roles and profiles
pattern](https://puppetlabs.com/learn/roles-profiles-introduction) then it
makes sense to create your firewall rules in the profiles, so they
remain close to the services managed by the profile.

This is an example of firewall rules in a profile:

~~~puppet
class profile::apache {
  include apache
  apache::vhost { 'mysite': ensure => present }

  firewall { '100 allow http and https access':
    dport   => [80, 443],
    proto  => tcp,
    action => accept,
  }
}
~~~

### Rule inversion
Firewall rules may be inverted by prefixing the value of a parameter by "! ". If the value is an array, then every item in the array must be prefixed as iptables does not understand inverting a single value.

Parameters that understand inversion are: connmark, ctstate, destination, dport, dst\_range, dst\_type, iniface, outiface, port, proto, source, sport, src\_range, src\_type, and state.

Examples:

~~~puppet
firewall { '001 disallow esp protocol':
  action => 'accept',
  proto  => '! esp',
}
firewall { '002 drop NEW external website packets with FIN/RST/ACK set and SYN unset':
  chain     => 'INPUT',
  state     => 'NEW',
  action    => 'drop',
  proto     => 'tcp',
  sport     => ['! http', '! 443'],
  source    => '! 10.0.0.0/8',
  tcp_flags => '! FIN,SYN,RST,ACK SYN',
}
~~~

### Additional Uses for the Firewall Module

You can apply firewall rules to specific nodes. Usually, you will want to put the firewall rule in another class and apply that class to a node. Apply a rule to a node as follows:

~~~puppet
node 'some.node.com' {
  firewall { '111 open port 111':
    dport => 111,
  }
}
~~~

You can also do more complex things with the `firewall` resource. This example sets up static NAT for the source network 10.1.2.0/24:

~~~puppet
firewall { '100 snat for network foo2':
  chain    => 'POSTROUTING',
  jump     => 'MASQUERADE',
  proto    => 'all',
  outiface => 'eth0',
  source   => '10.1.2.0/24',
  table    => 'nat',
}
~~~


You can also change the TCP MSS value for VPN client traffic:

~~~puppet
firewall { '110 TCPMSS for VPN clients':
  chain     => 'FORWARD',
  table     => 'mangle',
  source    => '10.0.2.0/24',
  proto     => tcp,
  tcp_flags => 'SYN,RST SYN',
  mss       => '1361:1541',
  set_mss   => '1360',
  jump      => 'TCPMSS',
}
~~~

The following will mirror all traffic sent to the server to a secondary host on the LAN with the TEE target:

~~~puppet
firewall { '503 Mirror traffic to IDS':
  proto   => all,
  jump    => 'TEE',
  gateway => '10.0.0.2',
  chain   => 'PREROUTING',
  table   => 'mangle',
}
~~~

The following example creates a new chain and forwards any port 5000 access to it.
~~~puppet
firewall { '100 forward to MY_CHAIN':
  chain   => 'INPUT',
  jump    => 'MY_CHAIN',
}
# The namevar here is in the format chain_name:table:protocol
firewallchain { 'MY_CHAIN:filter:IPv4':
  ensure  => present,
}
firewall { '100 my rule':
  chain   => 'MY_CHAIN',
  action  => 'accept',
  proto   => 'tcp',
  dport   => 5000,
}
~~~

### Additional Information

Access the inline documentation:

    puppet describe firewall

Or

    puppet doc -r type
    (and search for firewall)

## Reference

Classes:

* [firewall](#class-firewall)

Types:

* [firewall](#type-firewall)
* [firewallchain](#type-firewallchain)

Facts:

* [ip6tables_version](#fact-ip6tablesversion)
* [iptables_version](#fact-iptablesversion)
* [iptables_persistent_version](#fact-iptablespersistentversion)

### Class: firewall

Performs the basic setup tasks required for using the firewall resources.

At the moment this takes care of:

* iptables-persistent package installation

Include the `firewall` class for nodes that need to use the resources in this module:

    class { 'firewall': }

#### ensure

Parameter that controls the state of the iptables service on your system, allowing you to disable iptables if you want.

`ensure` can either be 'running' or 'stopped'. Defaults to 'running'.

#### package

Specify the platform-specific package(s) to install. Defaults defined in `firewall::params`.

#### pkg_ensure

Parameter that controls the state of the iptables package on your system, allowing you to update it if you wish.

`ensure` can either be 'present' or 'latest'. Defaults to 'present'.

#### service

Specify the platform-specific service(s) to start or stop. Defaults defined in `firewall::params`.

###Type: firewall

This type enables you to manage firewall rules within Puppet.

#### Providers
**Note:** Not all features are available with all providers.

 * `ip6tables`: Ip6tables type provider
    * Required binaries: `ip6tables-save`, `ip6tables`.
    * Supported features: `address_type`, `connection_limiting`, `dnat`, `hop_limiting`, `icmp_match`, `interface_match`, `iprange`, `ipsec_dir`, `ipsec_policy`, `ipset`, `iptables`, `isfirstfrag`, `ishasmorefrags`, `islastfrag`, `log_level`, `log_prefix`, `log_uid`, `mark`, `mask`, `mss`, `owner`, `pkttype`, `rate_limiting`, `recent_limiting`, `reject_type`, `snat`, `socket`, `state_match`, `tcp_flags`.

* `iptables`: Iptables type provider
    * Required binaries: `iptables-save`, `iptables`.
    * Default for `kernel` == `linux`.
    * Supported features: `address_type`, `clusterip`, `connection_limiting`, `dnat`, `icmp_match`, `interface_match`, `iprange`, `ipsec_dir`, `ipsec_policy`, `ipset`, `iptables`, `isfragment`, `log_level`, `log_prefix`, `log_uid`, `mark`, `mask`, `mss`, `netmap`, `owner`, `pkttype`, `rate_limiting`, `recent_limiting`, `reject_type`, `snat`, `socket`, `state_match`, `tcp_flags`.

**Autorequires:**

If Puppet is managing the iptables or ip6tables chains specified in the `chain` or `jump` parameters, the firewall resource will autorequire those firewallchain resources.

If Puppet is managing the iptables or iptables-persistent packages, and the provider is iptables or ip6tables, the firewall resource will autorequire those packages to ensure that any required binaries are installed.

#### Features

* `address_type`: The ability to match on source or destination address type.

* `clusterip`: Configure a simple cluster of nodes that share a certain IP and MAC address without an explicit load balancer in front of them.

* `connection_limiting`: Connection limiting features.

* `dnat`: Destination NATing.

* `hop_limiting`: Hop limiting features.

* `icmp_match`: The ability to match ICMP types.

* `interface_match`: Interface matching.

* `iprange`: The ability to match on source or destination IP range.

* `ipsec_dir`: The ability to match IPsec policy direction.

* `ipsec_policy`: The ability to match IPsec policy.

* `iptables`: The provider provides iptables features.

* `isfirstfrag`: The ability to match the first fragment of a fragmented ipv6 packet.

* `isfragment`: The ability to match fragments.

* `ishasmorefrags`: The ability to match a non-last fragment of a fragmented ipv6 packet.

* `islastfrag`: The ability to match the last fragment of an ipv6 packet.

* `log_level`: The ability to control the log level.

* `log_prefix`: The ability to add prefixes to log messages.

* `log_uid`: The ability to log the userid of the process which generated the packet.

* `mark`: The ability to match or set the netfilter mark value associated with the packet.

* `mask`:  The ability to match recent rules based on the ipv4 mask.

* `owner`: The ability to match owners.

* `pkttype`: The ability to match a packet type.

* `rate_limiting`: Rate limiting features.

* `recent_limiting`: The netfilter recent module.

* `reject_type`: The ability to control reject messages.

* `set_mss`: Set the TCP MSS of a packet.

* `snat`: Source NATing.

* `socket`: The ability to match open sockets.

* `state_match`: The ability to match stateful firewall states.

* `tcp_flags`: The ability to match on particular TCP flag settings.

* `netmap`: The ability to map entire subnets via source or destination nat rules.

#### Parameters

* `action`: This is the action to perform on a match. Valid values for this action are:
  * 'accept': The packet is accepted.
  * 'reject': The packet is rejected with a suitable ICMP response.
  * 'drop': The packet is dropped.

   If you specify no value it will simply match the rule but perform no action unless you provide a provider-specific parameter (such as `jump`).

* `burst`: Rate limiting burst value (per second) before limit checks apply. Values must match '/^\d+$/'. Requires the `rate_limiting` feature.

* `clusterip_new`: Create a new ClusterIP. You always have to set this on the first rule for a given ClusterIP. Requires the `clusterip` feature.

* `clusterip_hashmode`: Specify the hashing mode. Valid values are sourceip, sourceip-sourceport, sourceip-sourceport-destport. Requires the `clusterip` feature.

* `clusterip_clustermac`: Specify the ClusterIP MAC address. Has to be a link-layer multicast address. Requires the `clusterip` feature.

* `clusterip_total_nodes`: Number of total nodes within this cluster. Requires the `clusterip` feature.

* `clusterip_local_node`: Local node number within this cluster. Requires the `clusterip` feature.

* `clusterip_hash_init`: Specify the random seed used for hash initialization. Requires the `clusterip` feature.

* `chain`: Name of the chain to use. You can provide a user-based chain or use one of the following built-in chains:'INPUT','FORWARD','OUTPUT','PREROUTING', or 'POSTROUTING'. The default value is 'INPUT'. Values must match '/^[a-zA-Z0-9\-_]+$/'. Requires the `iptables` feature.

* `checksum_fill`: When using a `jump` value of 'CHECKSUM', this boolean makes sure that a checksum is calculated and filled in a packet that lacks a checksum. Valid values are 'true' or 'false'. Requires the `iptables` feature.

* `clamp_mss_to_pmtu`: Enables PMTU Clamping support when using a jump target of 'TCPMSS'. Valid values are 'true' or 'false'.

* `connlimit_above`: Connection limiting value for matched connections above n. Values must match '/^\d+$/'. Requires the `connection_limiting` feature.

* `connlimit_mask`: Connection limiting by subnet mask for matched connections. Apply a subnet mask of /0 to /32 for IPv4, and a subnet mask of /0 to /128 for IPv6. Values must match '/^\d+$/'. Requires the `connection_limiting` feature.

* `connmark`: Match the Netfilter mark value associated with the packet. Accepts values `mark/mask` or `mark`. These will be converted to hex if they are not hex already. Requires the `mark` feature.

* `ctstate`: Matches a packet based on its state in the firewall stateful inspection table, using the conntrack module. Valid values are: 'INVALID', 'ESTABLISHED', 'NEW', 'RELATED'. Requires the `state_match` feature.

* `date_start`: Start Date/Time for the rule to match, which must be in ISO 8601 "T" notation. The possible time range is '1970-01-01T00:00:00' to '2038-01-19T04:17:07'

* `date_stop`: End Date/Time for the rule to match, which must be in ISO 8601 "T" notation. The possible time range is '1970-01-01T00:00:00' to '2038-01-19T04:17:07'

* `destination`: The destination address to match. For example: `destination => '192.168.1.0/24'`. You can also negate a mask by putting ! in front. For example: `destination  => '! 192.168.2.0/24'`. The destination can also be an IPv6 address if your provider supports it.

  For some firewall providers you can pass a range of ports in the format: 'start number-end number'. For example, '1-1024' would cover ports 1 to 1024.

* `dport`: The destination port to match for this filter (if the protocol supports ports). Will accept a single element or an array. For some firewall providers you can pass a range of ports in the format: 'start number-end number'. For example, '1-1024' would cover ports 1 to 1024.

* `dst_range`: The destination IP range. For example: `dst_range => '192.168.1.1-192.168.1.10'`.

  The destination IP range is must in 'IP1-IP2' format. Values in the range must be valid IPv4 or IPv6 addresses. Requires the `iprange` feature.

* `dst_type`: The destination address type. For example: `dst_type => 'LOCAL'`.

  Valid values are:

  * 'UNSPEC': an unspecified address
  * 'UNICAST': a unicast address
  * 'LOCAL': a local address
  * 'BROADCAST': a broadcast address
  * 'ANYCAST': an anycast packet
  * 'MULTICAST': a multicast address
  * 'BLACKHOLE': a blackhole address
  * 'UNREACHABLE': an unreachable address
  * 'PROHIBIT': a prohibited address
  * 'THROW': an unroutable address
  * 'XRESOLVE: an unresolvable address

  Requires the `address_type` feature.

* `ensure`: Ensures that the resource is present. Valid values are 'present', 'absent'. The default is 'present'.

* `gateway`: Used with TEE target to mirror traffic of a machine to a secondary host on the LAN.

* `gid`: GID or Group owner matching rule. Accepts a string argument only, as iptables does not accept multiple gid in a single statement. Requires the `owner` feature.

* `hop_limit`: Hop limiting value for matched packets. Values must match '/^\d+$/'. Requires the `hop_limiting` feature.

* `icmp`: When matching ICMP packets, this indicates the type of ICMP packet to match. A value of 'any' is not supported. To match any type of ICMP packet, the parameter should be omitted or undefined. Requires the `icmp_match` feature.

* `iniface`: Input interface to filter on. Values must match '/^!?\s?[a-zA-Z0-9\-\._\+\:]+$/'.  Requires the `interface_match` feature.  Supports interface alias (eth0:0) and negation.

* `ipsec_dir`: Sets the ipsec policy direction. Valid values are 'in', 'out'. Requires the `ipsec_dir` feature.

* `ipsec_policy`: Sets the ipsec policy type. Valid values are 'none', 'ipsec'. Requires the `ipsec_policy` feature.

* `ipset`: Matches IP sets. Value must be 'ipset_name (src|dst|src,dst)' and can be negated by putting ! in front. Requires ipset kernel module.

* `isfirstfrag`: If true, matches when the packet is the first fragment of a fragmented ipv6 packet. Cannot be negated. Supported by ipv6 only. Valid values are 'true', 'false'. Requires the `isfirstfrag` feature.

* `isfragment`: If 'true', matches when the packet is a tcp fragment of a fragmented packet. Supported by iptables only. Valid values are 'true', 'false'. Requires features `isfragment`.

* `ishasmorefrags`: If 'true', matches when the packet has the 'more fragments' bit set. Supported by ipv6 only. Valid values are 'true', 'false'. Requires the `ishasmorefrags` feature.

* `islastfrag`: If true, matches when the packet is the last fragment of a fragmented ipv6 packet. Supported by ipv6 only. Valid values are 'true', 'false'. Requires the `islastfrag`.

* `jump`: The value for the iptables `--jump` parameter. Any valid chain name is allowed, but normal values are: 'QUEUE', 'RETURN', 'DNAT', 'SNAT', 'LOG', 'MASQUERADE', 'REDIRECT', 'MARK', 'TCPMSS', 'DSCP'.

  For the values 'ACCEPT', 'DROP', and 'REJECT', you must use the generic `action` parameter. This is to enforce the use of generic parameters where possible for maximum cross-platform modeling.

  If you set both `accept` and `jump` parameters, you will get an error, because only one of the options should be set. Requires the `iptables` feature.

* `kernel_timezone`: Use the kernel timezone instead of UTC to determine whether a packet meets the time regulations.

* `limit`: Rate limiting value for matched packets. The format is: 'rate/[/second/|/minute|/hour|/day]'. Example values are: '50/sec', '40/min', '30/hour', '10/day'. Requires the  `rate_limiting` feature.

* `line`: Read-only property for caching the rule line.

* `log_level`: When combined with `jump => 'LOG'` specifies the system log level to log to. Requires the `log_level` feature.

* `log_prefix`: When combined with `jump => 'LOG'` specifies the log prefix to use when logging. Requires the `log_prefix` feature.

* `log_uid`: The ability to log the userid of the process which generated the packet.

* `mask`: Sets the mask to use when `recent` is enabled. Requires the `mask` feature.

* `month_days`: Only match on the given days of the month. Possible values are '1' to '31'. Note that specifying '31' will not match on months that do not have a 31st day; the same goes for 28- or 29-day February.

* `match_mark`: Match the Netfilter mark value associated with the packet. Accepts either of mark/mask or mark. These will be converted to hex if they are not already. Requires the `mark` feature.

* `mss`: Sets a given TCP MSS value or range to match.

* `name`: The canonical name of the rule. This name is also used for ordering, so make sure you prefix the rule with a number. For example:

  ~~~puppet
firewall { '000 this runs first':
  # this rule will run first
}
firewall { '999 this runs last':
  # this rule will run last
}
  ~~~

  Depending on the provider, the name of the rule can be stored using the comment feature of the underlying firewall subsystem. Values must match '/^\d+[[:graph:][:space:]]+$/'.

* `outiface`: Output interface to filter on. Values must match '/^!?\s?[a-zA-Z0-9\-\._\+\:]+$/'.  Requires the `interface_match` feature.  Supports interface alias (eth0:0) and negation.

* `physdev_in`: Match if the packet is entering a bridge from the given interface. Values must match '/^[a-zA-Z0-9\-\._\+]+$/'.

* `physdev_out`: Match if the packet is leaving a bridge via the given interface. Values must match '/^[a-zA-Z0-9\-\._\+]+$/'.

* `physdev_is_bridged`: Match if the packet is transversing a bridge. Valid values are true or false.

* `pkttype`: Sets the packet type to match. Valid values are: 'unicast', 'broadcast', and'multicast'. Requires the `pkttype` feature.

* `port`: *DEPRECATED* Using the unspecific 'port' parameter can lead to firewall rules that are unexpectedly too lax. It is recommended to always use the specific dport and sport parameters to avoid this ambiguity. The destination or source port to match for this filter (if the protocol supports ports). Will accept a single element or an array. For some firewall providers you can pass a range of ports in the format: 'start number-end number'. For example, '1-1024' would cover ports 1 to 1024.

* `proto`: The specific protocol to match for this rule. This is 'tcp' by default. Valid values are:
  * 'tcp'
  * 'udp'
  * 'icmp'
  * 'ipv4'
  * 'ipv6'
  * 'ipv6-icmp'
  * 'esp'
  * 'ah'
  * 'vrrp'
  * 'igmp'
  * 'ipencap'
  * 'ospf'
  * 'gre'
  * 'all'

* `provider`: The specific backend to use for this firewall resource. You will seldom need to specify this --- Puppet will usually discover the appropriate provider for your platform. Available providers are ip6tables and iptables. See the [Providers](#providers) section above for details about these providers.

 * `random`: When using a `jump` value of 'MASQUERADE', 'DNAT', 'REDIRECT', or 'SNAT', this boolean will enable randomized port mapping. Valid values are true or false. Requires the `dnat` feature.

* `rdest`: If boolean 'true', adds the destination IP address to the list. Valid values are true or false. Requires the `recent_limiting` feature and the `recent` parameter.

* `reap`: Can only be used in conjunction with the `rseconds` parameter. If boolean 'true', this will purge entries older than 'seconds' as specified in `rseconds`. Valid values are true or false. Requires the `recent_limiting` feature and the `recent` parameter.

* `recent`: Enable the recent module. Valid values are: 'set', 'update', 'rcheck', or 'remove'. For example:

~~~puppet
# If anyone's appeared on the 'badguy' blacklist within
# the last 60 seconds, drop their traffic, and update the timestamp.
firewall { '100 Drop badguy traffic':
  recent   => 'update',
  rseconds => 60,
  rsource  => true,
  rname    => 'badguy',
  action   => 'DROP',
  chain    => 'FORWARD',
}
# No-one should be sending us traffic on eth0 from localhost
# Blacklist them
firewall { '101 blacklist strange traffic':
  recent      => 'set',
  rsource     => true,
  rname       => 'badguy',
  destination => '127.0.0.0/8',
  iniface     => 'eth0',
  action      => 'DROP',
  chain       => 'FORWARD',
}
~~~

  Requires the `recent_limiting` feature.

* `reject`: When combined with `jump => 'REJECT'`, you can specify a different ICMP response to be sent back to the packet sender. Requires the `reject_type` feature.

* `rhitcount`: Used in conjunction with `recent => 'update'` or `recent => 'rcheck'`. When used, this will narrow the match to happen only when the address is in the list and packets greater than or equal to the given value have been received. Requires the `recent_limiting` feature and the `recent` parameter.

* `rname`: Specify the name of the list. Takes a string argument. Requires the `recent_limiting` feature and the `recent` parameter.

* `rseconds`: Used in conjunction with `recent => 'rcheck'` or `recent => 'update'`. When used, this will narrow the match to only happen when the address is in the list and was seen within the last given number of seconds. Requires the `recent_limiting` feature and the `recent` parameter.

* `rsource`: If boolean 'true', adds the source IP address to the list. Valid values are 'true', 'false'. Requires the `recent_limiting` feature and the `recent` parameter.

* `rttl`: May only be used in conjunction with `recent => 'rcheck'` or `recent => 'update'`. If boolean 'true', this will narrow the match to happen only when the address is in the list and the TTL of the current packet matches that of the packet that hit the `recent => 'set'` rule. If you have problems with DoS attacks via bogus packets from fake source addresses, this parameter may help. Valid values are 'true', 'false'. Requires the `recent_limiting` feature and the `recent` parameter.

* `set_dscp`: When combined with `jump => 'DSCP'` specifies the dscp marking associated with the packet.

* `set_dscp_class`: When combined with `jump => 'DSCP'` specifies the class associated with the packet (valid values found here: http://www.cisco.com/c/en/us/support/docs/quality-of-service-qos/qos-packet-marking/10103-dscpvalues.html#packetclassification).

* `set_mark`: Set the Netfilter mark value associated with the packet. Accepts either  'mark/mask' or 'mark'. These will be converted to hex if they are not already. Requires the `mark` feature.

* `set_mss`: When combined with `jump => 'TCPMSS'` specifies the value of the MSS field.

* `socket`: If 'true', matches if an open socket can be found by doing a socket lookup on the packet. Valid values are 'true', 'false'. Requires the `socket` feature.

* `source`: The source address. For example: `source => '192.168.2.0/24'`. You can also negate a mask by putting ! in front. For example: `source => '! 192.168.2.0/24'`. The source can also be an IPv6 address if your provider supports it.

* `sport`: The source port to match for this filter (if the protocol supports ports). Will accept a single element or an array. For some firewall providers you can pass a range of ports in the format:'start number-end number'. For example, '1-1024' would cover ports 1 to 1024.

* `src_range`: The source IP range. For example: `src_range => '192.168.1.1-192.168.1.10'`. The source IP range must be in 'IP1-IP2' format. Values in the range must be valid IPv4 or IPv6 addresses. Requires the `iprange` feature.

* `src_type`: Specify the source address type. For example: `src_type => 'LOCAL'`.

  Valid values are:

  * 'UNSPEC': an unspecified address.
  * 'UNICAST': a unicast address.
  * 'LOCAL': a local address.
  * 'BROADCAST': a broadcast address.
  * 'ANYCAST': an anycast packet.
  * 'MULTICAST': a multicast address.
  * 'BLACKHOLE': a blackhole address.
  * 'UNREACHABLE': an unreachable address.
  * 'PROHIBIT': a prohibited address.
  * 'THROW': an unroutable address.
  * 'XRESOLVE': an unresolvable address.

  Requires the `address_type` feature.

* `stat_every`: Match one packet every nth packet. Requires `stat_mode => 'nth'`

* `stat_mode`: Set the matching mode for statistic matching. Supported modes are `random` and `nth`.

* `stat_packet`: Set the initial counter value for the nth mode. Must be between 0 and the value of `stat_every`. Defaults to 0. Requires `stat_mode => 'nth'`

* `stat_probability`: Set the probability from 0 to 1 for a packet to be randomly matched. It works only with `stat_mode => 'random'`.

* `state`: Matches a packet based on its state in the firewall stateful inspection table. Valid values are: 'INVALID', 'ESTABLISHED', 'NEW', 'RELATED'. Requires the `state_match` feature.

* `table`: Table to use. Valid values are: 'nat', 'mangle', 'filter', 'raw', 'rawpost'. By default the setting is 'filter'. Requires the `iptables` feature.

* `tcp_flags`: Match when the TCP flags are as specified. Set as a string with a list of comma-separated flag names for the mask, then a space, then a comma-separated list of flags that should be set. The flags are: 'SYN', 'ACK', 'FIN', 'RST', 'URG', 'PSH', 'ALL', 'NONE'.

   Note that you specify flags in the order that iptables `--list` rules would list them to avoid having Puppet think you changed the flags. For example, 'FIN,SYN,RST,ACK SYN' matches packets with the SYN bit set and the ACK, RST and FIN bits cleared. Such packets are used to request TCP connection initiation. Requires the `tcp_flags` feature.

* `time_contiguous`: When the `time_stop` value is smaller than the `time_start` value, match this as a single time period instead of distinct intervals.

* `time_start`: Start time for the rule to match. The possible time range is '00:00:00' to '23:59:59'. Leading zeroes are allowed (e.g. '06:03') and correctly interpreted as base-10.

* `time_stop`: End time for the rule to match. The possible time range is '00:00:00' to '23:59:59'. Leading zeroes are allowed (e.g. '06:03') and correctly interpreted as base-10.

* `todest`: When using `jump => 'DNAT'`, you can specify the new destination address using this parameter. Requires the `dnat` feature.

* `toports`: For DNAT this is the port that will replace the destination port. Requires the `dnat` feature.

* `tosource`: When using `jump => 'SNAT'`, you can specify the new source address using this parameter. Requires the `snat` feature.

* `to`: When using `jump => 'NETMAP'`, you can specify a source or destination subnet to nat to. Requires the `netmap` feature`.

* `uid`: UID or Username owner matching rule. Accepts a string argument only, as iptables does not accept multiple uid in a single statement. Requires the `owner` feature.

* `week_days`: Only match on the given weekdays. Possible values are 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'.

### Type: firewallchain

Enables you to manage rule chains for firewalls.

Currently this type supports only iptables, ip6tables, and ebtables on Linux. It also provides support for setting the default policy on chains and tables that allow it.

**Autorequires**: If Puppet is managing the iptables or iptables-persistent packages, and the provider is iptables_chain, the firewall resource will autorequire those packages to ensure that any required binaries are installed.

#### Providers

`iptables_chain` is the only provider that supports firewallchain.

#### Features

* `iptables_chain`: The provider provides iptables chain features.
* `policy`: Default policy (inbuilt chains only).

#### Parameters

* `ensure`: Ensures that the resource is present. Valid values are 'present', 'absent'.

* `ignore`: Regex to perform on firewall rules to exempt unmanaged rules from purging (when enabled). This is matched against the output of iptables-save. This can be a single regex or an array of them. To support flags, use the ruby inline flag mechanism: a regex such as '/foo/i' can be written as '(?i)foo' or '(?i:foo)'. Only when purge is 'true'.

  Full example:
~~~puppet
firewallchain { 'INPUT:filter:IPv4':
  purge  => true,
  ignore => [
    # ignore the fail2ban jump rule
    '-j fail2ban-ssh',
    # ignore any rules with "ignore" (case insensitive) in the comment in the rule
    '--comment "[^"](?i:ignore)[^"]"',
    ],
}
~~~

* `name`: Specify the canonical name of the chain. For iptables the format must be {chain}:{table}:{protocol}.

* `policy`: Set the action the packet will perform when the end of the chain is reached. It can only be set on inbuilt chains ('INPUT', 'FORWARD', 'OUTPUT', 'PREROUTING', 'POSTROUTING'). Valid values are:

  * 'accept': The packet is accepted.
  * 'drop': The packet is dropped.
  * 'queue': The packet is passed userspace.
  * 'return': The packet is returned to calling (jump) queue or to the default of inbuilt chains.

* `provider`: The specific backend to use for this firewallchain resource. You will seldom need to specify this --- Puppet will usually discover the appropriate provider for your platform. The only available provider is:

  `iptables_chain`: iptables chain provider

    * Required binaries: `ebtables-save`, `ebtables`, `ip6tables-save`, `ip6tables`, `iptables-save`, `iptables`.
    * Default for `kernel` == `linux`.
    * Supported features: `iptables_chain`, `policy`.

* `purge`: Purge unmanaged firewall rules in this chain. Valid values are 'false', 'true'.

**Note** This `purge` is purging unmanaged rules in a firewall chain, not unmanaged firewall chains. To purge unmanaged firewall chains, use the following instead.

~~~puppet
resources { 'firewallchain':
  purge => true,
}
~~~

### Fact: ip6tables_version

A Facter fact that can be used to determine what the default version of ip6tables is for your operating system/distribution.

### Fact: iptables_version

A Facter fact that can be used to determine what the default version of iptables is for your operating system/distribution.

### Fact: iptables_persistent_version

Retrieves the version of iptables-persistent from your OS. This is a Debian/Ubuntu specific fact.

## Limitations

### SLES

The `socket` parameter is not supported on SLES.  In this release it will cause
the catalog to fail with iptables failures, rather than correctly warn you that
the features are unusable.

### Oracle Enterprise Linux

The `socket` and `owner` parameters are unsupported on Oracle Enterprise Linux
when the "Unbreakable" kernel is used. These may function correctly when using
the stock RedHat kernel instead. Declaring either of these parameters on an
unsupported system will result in iptable rules failing to apply.

### Debian 8 Support

As Puppet Enterprise itself does not yet support Debian 8, use of this module with Puppet Enterprise under a Debian 8
system should be regarded as experimental.

### Known Issues
 
#### MCollective causes PE to reverse firewall rule order

Firewall rules appear in reverse order if you use MCollective to run Puppet in Puppet Enterprise 2016.1, 2015.3, 2015.2, or 3.8.x.

If you use MCollective to kick off Puppet runs (`mco puppet runonce -I agent.example.com`) while also using the [`puppetlabs/firewall`](https://forge.puppet.com/puppetlabs/firewall) module, your firewall rules might be listed in reverse order.

In many firewall configurations, the last rule drops all packets. If the rule order is reversed, this rule is listed first and network connectivity fails.

To prevent this issue, do not use MCollective to kick off Puppet runs. Use any of the following instead:

* Run `puppet agent -t` on the command line.
* Use a cron job.
* Click [Run Puppet](https://docs.puppet.com/pe/2016.1/console_classes_groups_running_puppet.html#run-puppet-on-an-individual-node) in the console.

#### Reporting Issues

Report found bugs in JIRA:

<http://tickets.puppetlabs.com>

## Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)

For this particular module, please also read CONTRIBUTING.md before contributing.

Currently we support:

* iptables
* ip6tables
* ebtables (chains only)

### Testing

Make sure you have:

* rake
* bundler

Install the necessary gems:

    bundle install

And run the tests from the root of the source code:

    rake test

If you have a copy of Vagrant 1.1.0 you can also run the system tests:

    RS_SET=ubuntu-1404-x64 rspec spec/acceptance
    RS_SET=centos-64-x64 rspec spec/acceptance
