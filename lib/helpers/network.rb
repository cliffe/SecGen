require_relative './print.rb'

class NetworkFunctions

  def self.build_network_map(systems, options)

    base_vlan = options[:proxmoxvlan] ? options[:proxmoxvlan].to_i : 0
    options[:network_map] = {}

    # Build unique_id -> system_name lookup
    uid_to_system_name = {}
    systems.each do |system|
      system.network_module_selections.each do |mod|
        uid_to_system_name[mod.unique_id] = system.name
      end
    end

    systems.each do |system|
      Print.debug "system: #{system.name} module_selections: #{system.module_selections.map(&:unique_id).inspect}"
    end

    # First pass — register all specific IP_address entries
    systems.each do |system|
      system.network_module_selections.each do |mod|
        next unless mod.module_type == 'network'
        next unless mod.received_inputs.include?('IP_address')

        ip = mod.received_inputs['IP_address'].first
        next if ip.nil?
        Print.debug "First pass: #{mod.unique_id} IP_address=#{ip} received_inputs=#{mod.received_inputs.inspect}"

        vlan = compute_vlan(mod, base_vlan)
        subnet = ip.split('.')[0..2].join('.') + '.0'

        unless options[:network_map].key?(vlan)
          options[:network_map][vlan] = { vlan: vlan, subnet: subnet, ips: {}, ips_by_system: {}, used_octets: [], gateway: {}, dns_nameservers: {}, routes: {} }
        end

        # Check the IP being added is consistent with the subnet already registered for this VLAN
        map_subnet = options[:network_map][vlan][:subnet]
        if map_subnet != subnet
          Print.err "Network misconfiguration: VLAN #{vlan} has conflicting subnets -- #{map_subnet} (previously registered) and #{subnet} (#{mod.unique_id})"
          exit 1
        end

        options[:network_map][vlan][:used_octets] << ip.split('.').last.to_i
        options[:network_map][vlan][:ips][mod.unique_id] = ip
        options[:network_map][vlan][:ips_by_system][uid_to_system_name[mod.unique_id]] = ip
        options[:network_map][vlan][:gateway][mod.unique_id] = mod.received_inputs['default_gateway']&.first&.then { |v| v.empty? ? nil : v }
        options[:network_map][vlan][:dns_nameservers][mod.unique_id] = mod.received_inputs['dns_nameservers']&.reject(&:empty?)&.join(' ')&.then { |v| v.empty? ? nil : v }
        options[:network_map][vlan][:routes][mod.unique_id] = mod.received_inputs['routes']&.reject(&:empty?) || []

      end
    end


    # Second pass — auto-assign IPs for range entries, skipping any claimed octets
    systems.each do |system|
      is_windows = system.network_module_selections.any? { |m| m.module_type == 'base' && m.attributes['platform']&.first&.downcase == 'windows' }

      system.network_module_selections.each do |mod|
        next unless mod.module_type == 'network'
        next if mod.received_inputs.include?('IP_address')

        if is_windows && (mod.received_inputs['default_gateway']&.reject(&:empty?)&.any? ||
          mod.received_inputs['dns_nameservers']&.reject(&:empty?)&.any? ||
          mod.received_inputs['routes']&.reject(&:empty?)&.any?)

          Print.err "Network misconfiguration: system '#{system.name}' is a Windows guest but has default_gateway, dns_nameservers, or routes configured -- these are only supported on Linux guests."
          exit 1

        end

        ip_range = mod.received_inputs['range']&.first
        next if ip_range.nil?

        if ip_range == 'dhcp'
          if mod.attributes['type']&.first == 'private_network'
            Print.err "Network error: #{mod.unique_id} has range=dhcp on a private_network -- did you mean to use a public_network module instead?"
            exit 1
          end
          next
        end

        vlan = compute_vlan(mod, base_vlan)

        Print.debug "Second pass: #{mod.unique_id} range=#{ip_range} vlan=#{vlan}"
        subnet = ip_range.split('.')[0..2].join('.') + '.0'

        unless options[:network_map].key?(vlan)
          options[:network_map][vlan] = { vlan: vlan, subnet: subnet, ips: {}, ips_by_system: {}, next_octet: 1, used_octets: [], gateway: {}, dns_nameservers: {}, routes: {} }
        end

        # Always use the subnet already stored in the map, not the locally derived one
        # (they may differ if a different range was registered first for this VLAN)
        map_subnet = options[:network_map][vlan][:subnet]

        if map_subnet != subnet
          Print.debug "Subnet mismatch: map=#{map_subnet} derived=#{subnet} explicit_inputs=#{mod.explicit_inputs.inspect}"
          if mod.explicit_inputs.include?('range')
            # This module explicitly set a conflicting range — scenario authoring error
            Print.err "Network misconfiguration: VLAN #{vlan} has conflicting subnets -- #{map_subnet} (previously registered) and #{subnet} (#{mod.unique_id})"
            exit 1
          end
          # Otherwise came from default generator — silently adopt established subnet
        end

        if ip_range.include?('/')
          Print.err "Network misconfiguration: range '#{ip_range}' for #{mod.unique_id} must not use CIDR notation -- use a plain subnet address ending in .0 (e.g. 172.17.0.0)."
          exit 1
        end

        if ip_range.split('.').last.to_i != 0
          Print.err "Network misconfiguration: range '#{ip_range}' for #{mod.unique_id} has a non-zero last octet -- ranges must end in .0 (e.g. 172.17.0.0). Did you mean to use IP_address instead?"
          exit 1
        end

        next_octet = options[:network_map][vlan][:next_octet] || 1
        begin
          next_octet += 1
          next_octet %= 254
        end while options[:network_map][vlan][:used_octets].include?(next_octet)

        options[:network_map][vlan][:next_octet] = next_octet
        options[:network_map][vlan][:used_octets] << next_octet
        options[:network_map][vlan][:gateway][mod.unique_id] = mod.received_inputs['default_gateway']&.first&.then { |v| v.empty? ? nil : v }
        options[:network_map][vlan][:dns_nameservers][mod.unique_id] = mod.received_inputs['dns_nameservers']&.reject(&:empty?)&.join(' ')&.then { |v| v.empty? ? nil : v }
        options[:network_map][vlan][:routes][mod.unique_id] = mod.received_inputs['routes']&.reject(&:empty?) || []

        split_ip = map_subnet.split('.')
        split_ip[3] = next_octet.to_s
        resolved_ip = split_ip.join('.')

        options[:network_map][vlan][:ips][mod.unique_id] = resolved_ip
        options[:network_map][vlan][:ips_by_system][uid_to_system_name[mod.unique_id]] = resolved_ip
      end
    end

    # Third pass — apply --network-ranges overrides to the completed network map.
    if options[:ip_ranges] && !options[:proxmoxuser]
      subnets_in_vlan_order = options[:network_map].keys.sort.map { |vlan| options[:network_map][vlan][:subnet] }.uniq

      if options[:ip_ranges].size > subnets_in_vlan_order.size
        Print.err "Too many --network-ranges provided: #{options[:ip_ranges].size} given but scenario only has #{subnets_in_vlan_order.size} subnet(s). Remove the extra ranges and try again."
        exit 1
      end

      subnet_override_map = {}
      subnets_in_vlan_order.each_with_index do |subnet, i|
        if options[:ip_ranges][i]
          subnet_override_map[subnet] = options[:ip_ranges][i]
        else
          Print.err "Not enough --network-ranges provided: no override for subnet #{subnet} (VLAN #{options[:network_map].keys.sort[i]}). #{subnets_in_vlan_order.size} range(s) required, #{options[:ip_ranges].size} provided."
          exit 1
        end
      end

      Print.info "Network range overrides (by VLAN):"
      options[:network_map].keys.sort.each do |vlan|
        original_subnet = options[:network_map][vlan][:subnet]
        replacement = subnet_override_map[original_subnet] || original_subnet
        Print.info "  VLAN #{vlan}: #{original_subnet} -> #{replacement}"
      end

      subnet_override_map.values.each do |range|
        if range.include?('/')
          Print.err "Network misconfiguration: --network-ranges value '#{range}' must not use CIDR notation -- use a plain subnet address ending in .0 (e.g. 192.168.1.0)."
          exit 1
        end
        if range.split('.').last.to_i != 0
          Print.err "Network misconfiguration: --network-ranges value '#{range}' has a non-zero last octet -- ranges must end in .0 (e.g. 192.168.1.0)."
          exit 1
        end
      end

      options[:network_map].each do |vlan, network|
        original_subnet = network[:subnet]
        next unless subnet_override_map.key?(original_subnet)
        new_subnet = subnet_override_map[original_subnet]

        network[:subnet] = new_subnet
        network[:ips].transform_values! do |ip|
          last_octet = ip.split('.').last
          new_subnet.split('.')[0..2].join('.') + '.' + last_octet
        end
        network[:ips_by_system].transform_values! do |ip|
          last_octet = ip.split('.').last
          new_subnet.split('.')[0..2].join('.') + '.' + last_octet
        end
      end
    end

    Print.debug "Network map subnets: #{options[:network_map].map { |vlan, network| "VLAN #{vlan} => #{network[:subnet]}" }.join(', ')}"


    # Validate no duplicate IPs across the entire network map
    all_assigned_ips = {}
    all_assigned_subnets = {}
    options[:network_map].each do |vlan, network|
      # Check for duplicate subnets across different VLANs
      subnet = network[:subnet]
      if all_assigned_subnets.key?(subnet)
        existing_vlan = all_assigned_subnets[subnet]
        Print.err "Network misconfiguration: subnet #{subnet} is used on both VLAN #{existing_vlan} and VLAN #{vlan} -- the same subnet cannot span different VLANs"
        exit 1
      end
      all_assigned_subnets[subnet] = vlan

      # Check for duplicate IPs
      network[:ips].each do |unique_id, ip|
        if all_assigned_ips.key?(ip)
          existing_vlan = all_assigned_ips[ip][:vlan]
          existing_id = all_assigned_ips[ip][:unique_id]
          if existing_vlan != vlan
            Print.err "Network misconfiguration: IP #{ip} is assigned on both VLAN #{existing_vlan} and VLAN #{vlan} (#{existing_id} and #{unique_id}) -- the same IP cannot appear on different VLANs"
          else
            Print.err "Network misconfiguration: IP #{ip} is assigned twice on VLAN #{vlan} (#{existing_id} and #{unique_id}) -- check for duplicate network definitions"
          end
          exit 1
        end
        all_assigned_ips[ip] = { unique_id: unique_id, vlan: vlan }
      end
    end

    Print.debug "Full network map: #{options[:network_map].inspect}"

  end

  def self.compute_vlan(mod, base_vlan)
    vlan_index = mod.received_inputs['vlan']&.first&.to_i || 1
    vlan = base_vlan + (vlan_index * 100)
    # Wrap into valid 802.1Q range (1–4094)
    ((vlan - 1) % 4094) + 1
  end

  def self.resolve_deferred_inputs(systems, options)
    base_vlan = options[:proxmoxvlan] ? options[:proxmoxvlan].to_i : 0

      # Resolve deferred network_ip references into module_selectors received_inputs
      systems.each do |system|
        system.module_selectors.each do |mod|
          mod.deferred_network_inputs.each do |input_variable, refs|
            Print.debug "deferred_network_inputs: mod=#{mod.unique_id} input_variable=#{input_variable} refs=#{refs.inspect}"
            refs.each do |ref|
              Print.debug "ref: #{ref.inspect} ref[:vlan]=#{ref[:vlan].inspect}"
              vlan_tag = base_vlan + (ref[:vlan] * 100)

              unless options[:network_map].key?(vlan_tag)
                Print.err "network_ip resolution error: no network found for system '#{ref[:system]}' vlan #{ref[:vlan]} (tag #{vlan_tag}), referenced by #{mod.unique_id} into '#{input_variable}'"
                exit 1
            end

            network = options[:network_map][vlan_tag]
            matched_ip = network[:ips_by_system][ref[:system]]

            if matched_ip.nil?
              Print.err "network_ip resolution error: no IP found for system '#{ref[:system]}' on vlan #{ref[:vlan]}, referenced by #{mod.unique_id} into '#{input_variable}'"
              exit 1
            end

            (mod.received_inputs[input_variable] ||= []).push(matched_ip)
            Print.debug "Pre-resolved network_ip: #{mod.unique_id} '#{input_variable}' = #{matched_ip} (#{ref[:system]} vlan #{ref[:vlan]})"
          end
        end
      end
    end

    # Resolve deferred datastore network_ip references
    if options[:deferred_datastore_network_ips]
      options[:deferred_datastore_network_ips].each do |positional_id, ref|
        vlan_tag = base_vlan + (ref[:vlan] * 100)
        vlan_tag = ((vlan_tag - 1) % 4094) + 1

        unless options[:network_map].key?(vlan_tag)
          Print.err "network_ip datastore resolution error: no network found for system '#{ref[:system]}' vlan #{ref[:vlan]} (tag #{vlan_tag}), id #{positional_id} in datastore '#{ref[:datastore]}'"
          exit 1
        end

        network = options[:network_map][vlan_tag]
        matched_ip = network[:ips_by_system][ref[:system]]

        if matched_ip.nil?
          Print.err "network_ip datastore resolution error: no IP found for system '#{ref[:system]}' on vlan #{ref[:vlan]}, id #{positional_id} in datastore '#{ref[:datastore]}'"
          exit 1
        end

        datastore_name = ref[:datastore]
        if $datastore[datastore_name]
          idx = $datastore[datastore_name].index(positional_id)
          if idx
            $datastore[datastore_name][idx] = matched_ip
            Print.debug "Pre-resolved datastore network_ip: #{datastore_name}[#{idx}] = #{matched_ip} (#{ref[:system]} vlan #{ref[:vlan]})"
          else
            Print.err "network_ip datastore resolution error: id #{positional_id} not found in datastore '#{datastore_name}'"
            exit 1
          end
        end
      end
    end
  end

end
