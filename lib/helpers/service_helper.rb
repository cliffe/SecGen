require_relative '../objects/service.rb'
class ServiceHelper
  def get_service_object(service_hash)
    service = Service.new
    service.attributes[:name] = service_hash['name'] if service_hash['name']
    service.attributes[:type] = service_hash['type'] if service_hash['type']
    service.attributes[:details] = service_hash['details'] if service_hash['details']
    service.attributes[:puppets] = service_hash['puppets'] if service_hash['puppets']
    return service
  end
end