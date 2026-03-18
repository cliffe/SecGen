require_relative './print.rb'

class NetworkFunctions

  def self.build_network_map(systems, options)

    base_vlan = options[:proxmoxvlan] ? options[:proxmoxvlan].to_i : 0
    options[:network_map] = {}

    # First pass — register all specific IP_address entries
    systems.each do |system|
      system.module_selections.each do |mod|
        next unless mod.module_type == 'network'
        next unless mod.received_inputs.include?('IP_address')

        ip = mod.received_inputs['IP_address'].first
        next if ip.nil?
        Print.debug "First pass: #{mod.unique_id} IP_address=#{ip} received_inputs=#{mod.received_inputs.inspect}"

        vlan = compute_vlan(mod, base_vlan)
        subnet = ip.split('.')[0..2].join('.') + '.0'

        unless options[:network_map].key?(vlan)
          options[:network_map][vlan] = { vlan: vlan, subnet: subnet, ips: {}, used_octets: [] }
        end

        # Check the IP being added is consistent with the subnet already registered for this VLAN
        map_subnet = options[:network_map][vlan][:subnet]
        if map_subnet != subnet
          Print.err "Network misconfiguration: VLAN #{vlan} has conflicting subnets -- #{map_subnet} (previously registered) and #{subnet} (#{mod.unique_id})"
          exit 1
        end

        options[:network_map][vlan][:used_octets] << ip.split('.').last.to_i
        options[:network_map][vlan][:ips][mod.unique_id] = ip

      end
    end


    # Second pass — auto-assign IPs for range entries, skipping any claimed octets
    systems.each do |system|
      system.module_selections.each do |mod|
        next unless mod.module_type == 'network'
        next if mod.received_inputs.include?('IP_address')

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
          options[:network_map][vlan] = { vlan: vlan, subnet: subnet, ips: {}, next_octet: 1, used_octets: [] }
        end

        # Always use the subnet already stored in the map, not the locally derived one
        # (they may differ if a different range was registered first for this VLAN)
        map_subnet = options[:network_map][vlan][:subnet]

        # If the subnet derived from ip_range doesn't match what's already in the map, that's a misconfiguration
        if map_subnet != subnet
          Print.err "Network misconfiguration: VLAN #{vlan} has conflicting subnets -- #{map_subnet} (previously registered) and #{subnet} (#{mod.unique_id})"
          exit 1
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

        split_ip = map_subnet.split('.')
        split_ip[3] = next_octet.to_s
        resolved_ip = split_ip.join('.')

        options[:network_map][vlan][:ips][mod.unique_id] = resolved_ip
      end
    end

    # Third pass — apply --network-ranges overrides to the completed network map.
    # Each distinct subnet in the map (sorted by VLAN) is substituted with the
    # corresponding CLI-provided range in order. Both IP_address and range entries
    # are remapped since we're rewriting IPs directly in the map.
    if options[:ip_ranges]
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

    base_vlan + (vlan_index * 100)
  end

end
