require_relative 'configuration.rb'
require_relative 'network_manager.rb'
require_relative 'service_manager.rb'
require_relative 'helpers/vulnerability_processor'
require_relative 'objects/base_box'
require_relative 'objects/network'
require_relative 'objects/service'
require_relative 'objects/system'
require_relative 'objects/vulnerability'
require 'nokogiri'

class SystemReader
	# initializes systems xml from BOXES_XML const
	def initialize()
		@vulnerability_processor = VulnerabilityProcessor.new
	end

	# uses nokogiri to extract all system information from scenario.xml will add it to the system class after
	# checking if the vulnerabilities / networks exist from system.rb
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

			system.css('vulnerabilities vulnerability').each do |v|
				vulnerability = Vulnerability.new
				# assign the value if the value is not nil (i.e. it's been specified in scenario.xml)
				vulnerability.type = v['type'] if v['type']
				vulnerability.privilege = v['privilege'] if v['privilege']
				vulnerability.cve = v['cve'] if v['cve']
				vulnerability.access = v['access'] if v['access']
				vulnerability.difficulty = v['difficulty'] if v['difficulty']
				vulnerability.cvss_rating = v['cvss_rating'] if v['cvss_rating']
				vulnerability.vector_string = v['vector_string'] if v['vector_string']
				vulns << vulnerability
			end

			system.css('services service').each do |v|
				service = Service.new
				service.name = v['name']
				service.details = v['details']
				service.type = v['type']
				services << service
			end
			
			system.css('networks network').each do |n|
				network = Network.new
				network.name = n['name']
				networks << network
			end
			
			puts "Processing system: " + id
			new_vulns = @vulnerability_processor.process(vulns)
      new_networks = NetworkManager.process(networks)
			new_services = ServiceManager.process(services, new_vulns)

			s = System.new(id, os, basebox, url, new_vulns, new_networks, new_services)
			if !s.is_valid_base
				generate_base(s)
			end

			systems << s
		end
		return systems
	end

	def generate_base(system)
		box = Configuration.bases.sample
		system.basebox = box.vagrantbase
		system.url = box.url
		return system
	end
end