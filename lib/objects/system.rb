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
    valid_base = System.bases

    valid_base.each do |b|
      if @basebox == b.vagrantbase
        @url = b.url
        return true
      end
    end
    return false
  end

  def self.networks
    if defined? @@networks
      return @@networks
    end
    return @@networks = Conf._get_list(NETWORKS_XML, "//networks/network", Network)
  end

  def self.bases
    if defined? @@bases
      return @@bases
    end
    return @@bases = Conf._get_list(BASE_XML, "//bases/base", Basebox)
  end

  def self.vulnerabilities
    if defined? @@vulnerabilities
      return @@vulnerabilities
    end
    return @@vulnerabilities = Conf._get_list(VULN_XML, "//vulnerabilities/vulnerability", Vulnerability)
  end

  def self.services
    if defined? @@services
      return @@services
    end
    return @@services = Conf._get_list(SERVICES_XML, "//services/service", Service)
  end
end