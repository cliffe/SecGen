require_relative('service_helper')

class ServiceProcessor

  def initialize
    @service_helper = ServiceHelper.new

    @all_services = get_services_array
    @legal_services = @all_services.clone
  end

  def process (selected_services, selected_vulns)
    return_services = {}

    # Remove services which we already have a vulnerability of the same type
    for vulnerability in selected_vulns
      @legal_services.delete_if { |service| service.attributes[:type] == vulnerability.attributes[:type] }
    end

    #Remove services which dont have the same attribute type
    for selected_service in selected_services
      @legal_services.delete_if { |service| service.attributes[:type] != selected_service.attributes[:type] }

      # Shuffle the legal services
      @legal_services.shuffle

      if @legal_services.length > 0
        return_services[selected_service.id] = @legal_services[0]
        puts "Selected secure service : " + @legal_services[0].attributes[:type]
      end

      # Remove duplicate services based on type, we only want 1 of each type on the box
      @legal_services.delete_if { |service| service.attributes[:type] == return_services[selected_service.id].attributes[:type] }

    end

    # TODO: Add validation if no services are selected but are defined

    return return_services.values
  end


  # Get array of service objects
  # @return [Array] Array containing service objects
  def get_services_array
    services_array = []
    Dir.glob("#{ROOT_DIR}/modules/services/**/**/secgen_metadata.xml").each do |file|
      services_hash = XmlSimple.xml_in(file, {})
      service = @service_helper.get_service_object(services_hash)
      services_array.push(service)
    end
    return services_array
  end
end