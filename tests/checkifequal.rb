require "test/unit"
require 'nokogiri'
require_relative "../system.rb"
#http://ruby-doc.org/stdlib-2.0.0/libdoc/test/unit/rdoc/Test/Unit/Assertions.html

class TestXMLIsEqual < Test::Unit::TestCase

	def setup
	  @vulns = []

	  @systems = []
	  doc = Nokogiri::XML(File.read(BOXES_DIR))
	  doc.xpath("//systems/system").each do |system|
	    id = system["id"]
	    os = system["os"]
	    base = system["basebox"]
	    vulns = system.css('vulnerabilities vulnerability').collect do |v|
	    	Vulnerability.new(v[:type],v[:privilege],v[:access],v[:puppet],v[:details])
	      end
	    networks = system.css('networks misc').collect { |n| n['name'] }

	    @systems << System.new(id, os, base, vulns, networks)
	  end
	end

	def test_system_data
		assert_equal(@systems[0].id, "system1")
		assert_equal(@systems[1].id, "system2")
		assert_equal(@systems[2].id, "system3")
	end


	def test_intersection
		list1 = [Vulnerability.new("nfs","root", "remote","", ""), Vulnerability.new("ftp","root", "remote","", "")]
		list2 = [Vulnerability.new("nfs","root", "remote","", ""), Vulnerability.new("samba","root", "remote","", ""), ]
		p ilist = list1 & list2

	end

	def test_system_vulnerabilities
		dummy_list = []

	  	empty_type = Vulnerability.new("","root", "remote","", "")

        valid_type = Vulnerability.new("ftp","root", "remote","", "")

        invalid_type = Vulnerability.new("THISISFAKE","root", "remote","", "")

	    valid_type = Vulnerability.new("nfs","root", "remote","", "")
	    valid_type1 = Vulnerability.new("nfs","root", "remote","", "")

	    
	    if empty_type.type == ""
	    	p empty_type
	    	vuln = generate_vulnerability(empty_type, Configuration.vulnerabilities, dummy_list)
	    	assert_not_match(vuln,"")
	    end
	end

	def test_system_networks
		#
	end
end