class NetworkManager
  # the user will either specify a blank misc type or a knownnetwork type

  # Check if given networks are valid if networks valid return the values, else display error message
  # @param networks [Array] Networks to check for validity
  # @param valid_network [String] Valid network value
  # @return [Array] Returns all the values for new_networks as an array
  def self.process(networks,valid_network)
    new_networks = {}
    # intersection of valid networks / user defined networks
    legal_networks = valid_network & networks
    networks.each do |network|
      # checks to see string is blank if so valid misc into a new hash map of vulnerabilities
      if network.name == ""
        random = valid_network.sample
        new_networks[random.id] = random
      else
        has_found = false
        # shuffle randomly selects first match
        legal_networks.shuffle.each do |valid|
          if network.name == valid.name
            network.range = valid.range unless not network.range.empty?
            # valid misc into a new hash map of networks
            new_networks[network.id] = network
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