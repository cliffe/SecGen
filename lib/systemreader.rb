require_relative 'system.rb'
require_relative 'objects/vulnerability'
require_relative 'helpers/vulnerability_processor'
class SystemReader
	# initializes systems xml from BOXES_XML const
	def initialize(systems_xml)
		@systems_xml = systems_xml
		@vulnerability_processor = VulnerabilityProcessor.new
	end

	# uses nokogiri to extract all system information from scenario.xml will add it to the system class after
	# checking if the vulnerabilities / networks exist from system.rb
	def systems
		systems = []
		doc = Nokogiri::XML(File.read(@systems_xml))
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
			
			new_networks = NetworkManager.process(networks, Conf.networks)
			# pass in the already selected set of vulnerabilities, and additional secure services to find
			new_services = ServiceManager.process(services, Conf.services, new_vulns)

			s = System.new(id, os, basebox, url, new_vulns, new_networks, new_services)
			if s.is_valid_base == false
				BaseManager.generate_base(s,Conf.bases)
			end

			systems << s
		end
		return systems
	end
end
