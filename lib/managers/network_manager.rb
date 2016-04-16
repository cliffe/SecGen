class NetworkManager
  # the user will either specify a blank misc type or a knownnetwork type
  def self.process(networks,valid_network)
    new_networks = {}
    # intersection of valid networks / user defined networks
    # legal_networks = valid_network & networks
    networks.each do |network|
      # checks to see string is blank if so valid misc into a new hash map of vulnerabilities
      if network.attributes[:name] == ""
        random = valid_network.sample
        new_networks[random.attributes[:id]] = random
      else
        has_found = false
        # shuffle randomly selects first match
        legal_networks.shuffle.each do |valid|
          if network.attributes[:name] == valid.attributes[:name]
            network.attributes[:range] = valid.attributes[:range] unless not network.attributes[:range].empty?
            # valid misc into a new hash map of networks
            new_networks[network.attributes[:id]] = network
            has_found = true
            break
          end
        end
        if not has_found
          p "Network was not found please check the xml scenario.xml"
          exit
        end
      end
    end
    return new_networks.values
  end
end