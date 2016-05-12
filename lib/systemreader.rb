require_relative 'configuration.rb'
require_relative 'managers/network_manager'
require_relative 'managers/service_manager'
require_relative 'managers/base_manager'
require_relative 'helpers/vulnerability_processor'
require_relative 'objects/base_box'
require_relative 'objects/network'
require_relative 'objects/service'
require_relative 'objects/wordpress/site'
require_relative 'objects/wordpress/user'
require_relative 'objects/system'
require_relative 'objects/vulnerability'
require_relative 'managers/site_manager'
require_relative 'helpers/plugin_helper'
require_relative 'managers/plugin_manager'
require_relative 'helpers/site_processor'

require 'nokogiri'

class SystemReader

	# initializes systems xml from BOXES_XML const
	def initialize
    @vulnerability_processor = VulnerabilityProcessor.new
    @plugin_helper = PluginHelper.new
    @site_manager = SiteManager.new

  end


	# uses nokogiri to extract all system information from scenario.xml will add it to the system class after
	# checking if the vulnerabilities / networks exist from system.rb
  # @return [Array] Array containing Systems objects
	def parse_systems
		systems = []
		doc = Nokogiri::XML(File.read(SCENARIO_XML))
		doc.xpath('//systems/system').each do |system|
			id = system['id']
			os = system['os']
			basebox = system['basebox']
			url = system['url']
			vulns = []
			networks = []
			services = []
			sites = []

      #todo: These should be moved into seperate 'processor' classes
      system.css('sites site').each do |site|
				site_obj = Site.new
				site_obj.name = site['name']
				site_obj.theme = site['theme']
				site_obj.admin_user = site['admin_user']
				site_obj.admin_password = site['admin_password']
				site_obj.admin_email = site['admin_email']

        site.css('vulnerable_plugins vulnerable_plugin').each do |vulnerable_plugin|
          site_obj.vulnerable_plugins << @plugin_helper.get_vulnerable_plugin_object(vulnerable_plugin)
        end

        site.css('secure_plugins secure_plugin').each do |secure_plugin|
          site_obj.secure_plugins << @plugin_helper.get_secure_plugin_object(secure_plugin)
        end
				sites << site_obj
			end

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
			
			puts "Processing system: #{id}"
			# vulns / networks are passed through to their manager and the program will create valid vulnerabilities / networks
			# depending on what the user has specified these two will return valid vulns to be used in vagrant file creation.
			new_vulns = @vulnerability_processor.process(vulns)
      new_sites = []
      sites.each do |site|
        new_sites << @site_manager.process(site)
      end



			new_networks = NetworkManager.process(networks, Configuration.networks)
			# pass in the already selected set of vulnerabilities, and additional secure services to find
			new_services = ServiceManager.process(services, Configuration.services, new_vulns)

      #create wp-cli script for site generation
      if new_sites.count > 0
        @site_processor = SiteProcessor.new(new_sites)
        @site_processor.generate_script
      end


			s = System.new(id, os, basebox, url, new_vulns, new_networks, new_services, new_sites)
			if s.is_valid_base == false
				BaseManager.generate_base(s,Configuration.bases)
			end

			systems << s
		end
		return systems
	end
end