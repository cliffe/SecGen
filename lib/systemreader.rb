require_relative 'configuration.rb'
require_relative 'managers/network_manager'
require_relative 'managers/base_manager'
require_relative 'helpers/service_processor'
require_relative 'helpers/vulnerability_processor'
require_relative 'objects/base_box'
require_relative 'objects/network'
require_relative 'objects/service'
require_relative 'objects/site'
require_relative 'objects/system'
require_relative 'objects/vulnerability'
require 'nokogiri'

class SystemReader

	# initializes systems xml from BOXES_XML const
	def initialize()
		@service_processor = ServiceProcessor.new
		@vulnerability_processor = VulnerabilityProcessor.new
	end

	# uses nokogiri to extract all system information from scenario.xml will add it to the system class after
	# checking if the vulnerabilities / networks exist from system.rb
  # @return [Array] Array containing Systems objects
	def parse_systems
		systems = []
		doc = Nokogiri::XML(File.read(SCENARIO_XML))
		doc.xpath("//systems/system").each do |system|
			id = system["id"]
			os = system["os"]
			basebox = system["basebox"]
			url = system["url"]
			vulns = []
			networks = []
			services = []
			sites = []

			system.css('sites site').each do |site|
				site_obj = Site.new
				site_obj.attributes[:name] = site['name']
				site_obj.attributes[:type] = site['type']
				sites << site_obj
			end
			system.css('vulnerabilities vulnerability').each do |v|
				vulnerability = Vulnerability.new
				# assign the value if the value is not nil (i.e. it's been specified in scenario.xml)
				vulnerability.attributes[:type] = v['type'] unless v['type'].nil?
				vulnerability.attributes[:privilege] = v['privilege'] unless v['privilege'].nil?
				vulnerability.attributes[:cve] = v['cve'] unless v['cve'].nil?
				vulnerability.attributes[:access] = v['access'] unless v['access'].nil?
				vulnerability.attributes[:difficulty] = v['difficulty'] unless v['difficulty'].nil?
				vulnerability.attributes[:cvss_rating] = v['cvss_rating'] unless v['cvss_rating'].nil?
				vulnerability.attributes[:vector_string] = v['vector_string'] unless v['vector_string'].nil?
				vulns << vulnerability
			end



			system.css('services service').each do |v|
				service = Service.new
				service.attributes[:name] = v['name']
				service.attributes[:details] = v['details']
				service.attributes[:type] = v['type']
				services << service
			end
			
			system.css('networks network').each do |n|
				network = Network.new
				network.attributes[:name] = n['name']
				network.attributes[:range] = n['range']
				networks << network
			end
			
			puts "Processing system: " + id
			# vulns / networks are passed through to their manager and the program will create valid vulnerabilities / networks
			# depending on what the user has specified these two will return valid vulns to be used in vagrant file creation.
			new_vulns = @vulnerability_processor.process(vulns)
			#puts new_vulns.inspect
			
			new_networks = NetworkManager.process(networks, Configuration.networks)
			# pass in the already selected set of vulnerabilities, and additional secure services to find
			new_services = @service_processor.process(services, new_vulns)

			s = System.new(id, os, basebox, url, new_vulns, new_networks, new_services, sites)
			if s.is_valid_base == false
				BaseManager.generate_base(s,Configuration.bases)
			end

			systems << s
		end

		return systems
	end
end