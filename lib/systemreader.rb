require_relative 'conf.rb'
require_relative 'network_manager.rb'
require_relative 'service_manager.rb'
require_relative 'base_manager.rb'
require_relative 'helpers/vulnerability_processor'
require_relative 'objects/base_box'
require_relative 'objects/network'
require_relative 'objects/service'
require_relative 'objects/system'
require_relative 'objects/vulnerability'

class SystemReader
	# initializes systems xml from BOXES_XML const
	def initialize()
		@vulnerability_processor = VulnerabilityProcessor.new
	end

	# uses nokogiri to extract all system information from scenario.xml will add it to the system class after
	# checking if the vulnerabilities / networks exist from system.rb
	def systems
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
				vulnerability.privilege = v['privilege']
				vulnerability.cve = v['cve']
				vulnerability.access = v['access']
				vulnerability.type = v['type']
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
			# vulns / networks are passed through to their manager and the program will create valid vulnerabilities / networks
			# depending on what the user has specified these two will return valid vulns to be used in vagrant file creation.
			new_vulns = @vulnerability_processor.process(vulns)
			#puts new_vulns.inspect
			
			new_networks = NetworkManager.process(networks, System.networks)
			# pass in the already selected set of vulnerabilities, and additional secure services to find
			new_services = ServiceManager.process(services, System.services, new_vulns)

			s = System.new(id, os, basebox, url, new_vulns, new_networks, new_services)
			if s.is_valid_base == false
				BaseManager.generate_base(s,Conf.bases)
			end

			systems << s
		end
		return systems
	end
end
