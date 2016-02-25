require 'nokogiri'
require_relative 'constants'


class System
    # can access from outside of class
    attr_accessor :id, :os, :url,:basebox, :networks, :vulns, :services

    #initalizes system variables
    def initialize(id, os, basebox, url, vulns=[], networks=[], services=[])
        @id = id
        @os = os
        @url = url
        @basebox = basebox
        @vulns = vulns
        @networks = networks
        @services = services
    end

    def is_valid_base
        valid_base = Conf.bases

        valid_base.each do |b|
            if @basebox == b.vagrantbase
                @url = b.url
                return true
            end
        end
        return false
    end
end


class Network
    attr_accessor :name, :range

    def initialize(name="", range="")
        @name = name
        @range = range
    end

    def id
        hash = @name + @range
        return hash
        # return string that connects everything to 1 massive string
    end

    def eql? other
        # checks if name matches networks.xml from scenario.xml
        other.kind_of?(self.class) && @name == other.name
    end

    def hash
        @type.hash
    end
end

class Service
    attr_accessor :name, :type, :details, :puppets

    def initialize(name="", type="", details="", puppets=[])
        @name = name
        @type = type
        @details = details
        @puppets = puppets
    end

    def eql? other
        other.kind_of?(self.class) && @type == other.type
    end

    def hash
        @type.hash
    end
    
    def id
        return @type
    end

end

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
			legal_services.delete_if{|x| x.type == a_vuln.type}
			wanted_services.delete_if{|x| x.type == a_vuln.type}
		end
		
		wanted_services.each do |service_query|

			# select based on selected type...

			# copy services array
			search_list = legal_services.clone
			# shuffle order of available secure services
			search_list.shuffle!
			# remove all the services that don't match the current selection (type, etc)
			if service_query.type.length > 0
				puts "Searching for service matching type: " + service_query.type
				search_list.delete_if{|x| x.type != service_query.type}
			end

			if search_list.length == 0
				STDERR.puts "Matching service was not found please check the xml scenario.xml"
				STDERR.puts "(note: you can only have one of each type of service per system)"
				exit
			else
				# use from the top of the top of the randomised list
				return_services[service_query.id] = search_list[0]
				if search_list[0].type.length > 0
					puts "Selected secure service : " + search_list[0].type
				end
				
				# enforce only one of any service type (remove from available)
				legal_services.delete_if{|x| x.type == service_query.type}
			end
		end
		return return_services.values
	end
end

class NetworkManager
    # the user will either specify a blank network type or a knownnetwork type
    def self.process(networks,valid_network)
        new_networks = {}
        # intersection of valid networks / user defined networks
        legal_networks = valid_network & networks
        networks.each do |network|
            # checks to see string is blank if so valid network into a new hash map of vulnerabilities 
            if network.name == ""
                random = valid_network.sample
                 new_networks[random.id] = random
            else
                has_found = false
                # shuffle randomly selects first match 
                legal_networks.shuffle.each do |valid|
                     if network.name == valid.name
                        network.range = valid.range unless not network.range.empty?
                        # valid network into a new hash map of networks 
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

class Basebox
    attr_accessor :name, :os, :distro, :vagrantbase, :url
end

class BaseManager
    def self.generate_base(system,bases)
        # takes a sample from bases.xml and then assigns it to system 
        box = bases.sample
        system.basebox = box.vagrantbase 
        system.url = box.url
    return system
    end
end



class Conf
    # this class uses nokogiri to grab all of the information from network.xml, bases.xml, and vulns.xml
    # then adds them to their specific class to do checking for legal in Manager.process
    def self.networks
        if defined? @@networks
            return @@networks
        end
        return @@networks = self._get_list(NETWORKS_XML, "//networks/network", Network)
    end

    def self.bases
        if defined? @@bases
            return @@bases
        end
        return @@bases = self._get_list(BASE_XML, "//bases/base", Basebox)
    end

    def self.vulnerabilities
        if defined? @@vulnerabilities
            return @@vulnerabilities
        end
        return @@vulnerabilities = self._get_list(VULN_XML, "//vulnerabilities/vulnerability", Vulnerability)
    end

    def self.services
        if defined? @@services
            return @@services
        end
        return @@services = self._get_list(SERVICES_XML, "//services/service", Service)
    end

    def self._get_list(xmlfile, xpath, cls)
        itemlist = []

        doc = Nokogiri::XML(File.read(xmlfile))
        doc.xpath(xpath).each do |item|
            # new class e.g networks
            obj = cls.new
            # checks to see if there are children puppet and add string to obj.puppets
            # move this to vulnerabilities/services classes?
            if defined? obj.puppets
                item.xpath("puppets/puppet").each { |c| obj.puppets << c.text.strip if not c.text.strip.empty? }
                item.xpath("ports/port").each { |c| obj.ports << c.text.strip if not c.text.strip.empty? }
            end
            # too specific move to vuln class end
            item.each do |attr, value|

                obj.send "#{attr}=", value
            end
            # vulnerability item
            itemlist << obj
        end
        return itemlist
    end
end
