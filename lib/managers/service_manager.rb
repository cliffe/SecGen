class ServiceManager
  # secure services are randomly selected from the definitions in services.xml (secure_services)
  # based on the attributes optionally specified in scenario.xml (want_services)
  # However, if the service type has already had a vulnerability assigned (selected_vulns), it is ignored here
  def self.process(want_services, secure_services, selected_vulns=[])
    return_services = {}
    legal_services = secure_services.clone
    wanted_services = want_services.clone

    # remove all services that have already been selected as vulns (from both the wanted and secure lists)
    selected_vulns.each do |a_vuln|
      legal_services.delete_if{|x| x.attributes['type'] == a_vuln.type}
      wanted_services.delete_if{|x| x.attributes['type'] == a_vuln.type}
    end

    wanted_services.each do |service_query|

      # select based on selected type...

      # copy services array
      search_list = legal_services.clone
      # shuffle order of available secure services
      search_list.shuffle!
      # remove all the services that don't match the current selection (type, etc)
      if service_query.attributes[:type].length > 0
        puts "Searching for service matching type: " + service_query.attributes[:type]
        search_list.delete_if{|x| x.attributes['type'] != service_query.attributes[:type]}
      end

      if search_list.length == 0
        STDERR.puts "Matching service was not found please check the xml scenario.xml"
        STDERR.puts "(note: you can only have one of each type of service per system)"
        exit
      else
        # use from the top of the top of the randomised list
        return_services[service_query.id] = search_list[0]
        if search_list[0].attributes['type'].length > 0
          puts "Selected secure service : " + search_list[0].attributes['type']
        end

        # enforce only one of any service type (remove from available)
        legal_services.delete_if{|x| x.attributes['type'] == service_query.attributes[:type]}
      end
    end
    return return_services.values
  end
end