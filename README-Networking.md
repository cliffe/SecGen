# Scenario Networking

SecGen supports defining private networks in scenarios, enabling multi-VM labs with isolated network segments. VMs are connected to networks via `<network>` elements within their `<system>` definitions, and receive IP addresses either auto-assigned from a randomised subnet range or as an explicitly defined static address.

IP assignment is fully randomised per build, where no hardcoded ranges are required in scenario definitions.

## Defining a network interface

Each network interface on a VM is declared with a `<network>` element inside the `<system>` block. The minimal form requires no inputs at all, where the subnet range and VLAN both have defaults:

### Default behaviour

```xml
<network type="private_network"/>
```

This auto-assigns an IP from a randomly generated subnet on VLAN 1. To place multiple VMs on the same subnet, give them the same `vlan` value. SecGen enforces a strict 1:1 relationship between VLANs and subnets, two VMs on the same VLAN must be on the same subnet, and the same subnet cannot span two VLANs.

The supported inputs are:

- `vlan`: logical VLAN index for this network (scenario-relative integer, defaults to `1`)
- `range`: subnet for auto-assigned IPs (e.g. `192.168.10.0`). If omitted, a random subnet is generated. The last octet is incremented per VM on this network, starting with `.2`.
- `IP_address`: assign a specific static IP to this interface instead of auto-assigning from a range.

`range` and `IP_address` are mutually exclusive. You can specify one or the other, not both.

### Specifying a VLAN or fixed subnet

 Optionally specify a `vlan` to group VMs onto the same subnet, and optionally a `range` to fix the subnet while keeping IP assignment dynamic:

```xml
<network type="private_network">
  <input into="vlan">
    <value>2</value>
  </input>
</network>
```

If `range` is also omitted, the default input for the `private_network` module applies a `random_ip_range` generator, which produces a randomly selected private subnet at build time. All VMs sharing the same `vlan` value will be placed on that same randomly generated subnet.

### Static IP address

Use the `<input into="IP_address">` parameter into a `<network>` element when a VM needs a known, fixed IP, e.g.:

```xml
<network type="private_network">
  <input into="vlan">
    <value>2</value>
  </input>
  <input into="IP_address">
    <value>10.10.10.1</value>
  </input>
</network>
```

Static IPs are registered first during network map construction, and auto-assigned IPs skip any octets already claimed by static assignments within the same subnet.

### Public network (DHCP)

In addition to `private_network`, SecGen supports `public_network` for VMs that need a DHCP-assigned address on the host's bridged network.

```xml
<network type="public_network"/>
```

A `public_network` has no `vlan`, `range`, or `IP_address` inputs — it always uses DHCP. It does not participate in the randomised network map and cannot be referenced with `<network_ip>`. A VM can have both a `public_network` and one or more `private_network` interfaces simultaneously.

## Multiple network interfaces

A system can have multiple `<network>` elements with different `vlan` values, placing the VM on several networks simultaneously:

```xml
<system>
  <system_name>gateway</system_name>
  <base platform="linux" distro="Debian 12" type="server"/>

  <network type="private_network">
    <input into="vlan"><value>1</value></input>
  </network>

  <network type="private_network">
    <input into="vlan"><value>2</value></input>
  </network>
</system>
```

Each NIC gets an IP auto-assigned from the randomised subnet for its VLAN.

## VLAN tags and the `--proxmox-vlan` option

The `vlan` value in a scenario is a logical index, not the actual VLAN tag used on the hypervisor. The real Proxmox VLAN tag is computed as:

```
proxmox_vlan_tag = base_vlan + (vlan_index * 100)
```

Where `base_vlan` is supplied via `--proxmox-vlan` (defaults to `0`).

For example, with `--proxmox-vlan 28`:

| Scenario `vlan` | Computed Proxmox VLAN tag |
|---|---|
| 1 | 128 |
| 2 | 228 |
| 3 | 328 |

This separates concurrent student deployments across non-overlapping VLAN ranges on shared Proxmox infrastructure, without scenario files needing to know anything about the deployment environment. The `--proxmox-vlan` value is typically randomised per deployment by the orchestration layer (e.g. Hacktivity).

SecGen validates that each logical VLAN index maps to exactly one subnet, and each subnet maps to exactly one VLAN. Conflicts raise an error at build time.

## Referencing another VM's IP: `<network_ip>`

Many scenarios need modules on one VM to know the IP address of another, for example, a client that connects to a server, or a Hackerbot configuration that references multiple hosts. Since IPs are randomised at build time, they cannot be hardcoded in the scenario. Instead, use the `<network_ip>` element.

`<network_ip>` is a deferred reference that resolves to the IP assigned to the named system on the named VLAN, after the network map has been built. It can appear anywhere a `<value>` or `<datastore>`, i.e. can be input directly into a module input, or into a datastore for later reuse.

```xml
<utility module_path=".*/some_client_module">
  <input into="server_ip">
    <network_ip system="webserver"/>
  </input>
</utility>
```

The attributes are:

- `system`: the `<system_name>` of the target VM
- `vlan`: the logical VLAN index (matching that VM's `<network>` definition). Defaults to `1` if omitted — only required when referencing a VM with multiple NICs on different VLANs.

## The `IP_addresses` datastore pattern

Many SecGen modules (Hackerbot generators, browser start pages, Pidgin, etc.) expect IP addresses to be passed in from a datastore by index. The conventional datastore name for this is `IP_addresses`.

**Old pattern (hardcoded):**
```xml
<input into_datastore="IP_addresses">
  <value>172.16.0.2</value>
  <value>172.16.0.3</value>
  <value>172.16.0.4</value>
</input>
```

**New pattern (randomised):**
```xml
<input into_datastore="IP_addresses">
  <network_ip system="desktop"/>
  <network_ip system="backup_server"/>
  <network_ip system="hackerbot_server"/>
</input>
```

Downstream modules consume these by index, unchanged from the old pattern:

```xml
<utility module_path=".*/pidgin">
  <input into="server_ip">
    <datastore access="2">IP_addresses</datastore>
  </input>
</utility>
```


The positional ordering is preserved, so all downstream `<datastore access="N">IP_addresses</datastore>` references continue to work without any changes. The only difference is that the IPs are now randomised rather than fixed.

NOTE: The `IP_addresses` datastore name is also significant for the now deprecated `--network-ranges` CLI option, which can override the subnet ranges used during a build. SecGen looks for this specific datastore name when applying that override.


### Mixing `<network_ip>` with static values

`<network_ip>` elements can be freely interleaved with `<value>` elements in the same datastore. This is useful when some IPs are fixed by design (e.g. a gateway) and others are randomised:

```xml
<input into_datastore="IP_addresses">
  <!-- [0] fixed gateway -->
  <value>10.0.0.1</value>
  <!-- [1] client VM — randomised -->
  <network_ip system="client"/>
  <!-- [2] server VM — randomised -->
  <network_ip system="server"/>
</input>
```

## Example scenarios

Four example scenarios are provided in `scenarios/examples/network_examples/`, each demonstrating a distinct aspect of the networking subsystem:

**[networks_default.xml](scenarios/examples/network_examples/networks_default.xml)** - covers the core `<network>` configuration options: the bare default (random subnet, VLAN 1), a static `IP_address` assignment, and a `public_network` interface alongside a `private_network` on the same VM.

**[networks_as_inputs.xml](scenarios/examples/network_examples/networks_as_inputs.xml)** - demonstrates `<network_ip>` used directly as module inputs, without an `IP_addresses` datastore. Uses real modules (ircd and Pidgin) to show a server binding to its randomised IP and a client connecting to it.

**[networks_with_datastores.xml](scenarios/examples/network_examples/networks_with_datastores.xml)** - demonstrates using `<network_ip>` tags to populate the IP_addresses datastore, which is then consumed by modules that require the full ordered list of scenario IPs. Uses the `hosts` utility module (which requires a positionally matched list of hostnames and IPs) and Pidgin (which connects to an irc server by IP) as real examples of the pattern.

**[networks_vlans.xml](scenarios/examples/network_examples/networks_vlans.xml)** - demonstrates multi-VLAN configuration across four VMs: explicit `vlan` inputs to separate networks, an explicit `range` to fix a subnet on a specific VLAN, and a multi-NIC gateway VM with one interface on each VLAN. VMs on the same VLAN automatically share the subnet and receive consecutive IPs without needing to repeat the range.