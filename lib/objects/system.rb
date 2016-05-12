class System
  # can access from outside of class

  # System's id number
  attr_accessor :id

  # Operating system running on the system
  attr_accessor :os

  # URL to the puppet basebox
  attr_accessor :url

  # Puppet basebox name
  attr_accessor :basebox

  # Networks used by the system
  attr_accessor :networks

  # Vulnerabilite's installed on the system
  attr_accessor :vulns

  # Services installed on the system
  attr_accessor :services

  # Sites to be served from the system
  attr_accessor :sites

  # Initalizes System object
  # @param id [String] Identifier string for system object
  # @param os [String] Operating system installed on the system
  # @param basebox [String] Puppet basebox used to create the system
  # @param url [String] url to the selected puppet basebox
  # @param vulns [Array] Array containing selected vulnerability objects
  # @param networks [Array] Array containing selected network objects
  # @param services [Array] Array containing selected services objects
  # @param sites [Array] Array containing selected sites objects
  def initialize(id, os, basebox, url, vulns=[], networks=[], services=[], sites=[])
    @id = id
    @os = os
    @url = url
    @basebox = basebox
    @vulns = vulns
    @networks = networks
    @services = services
    @sites = sites
  end

  # Checks to see if the selected base is a valid basebox and is in the vagrant file
  # @return [Boolean] Is the basebox valid
  def is_valid_base
    valid_base = Configuration.bases

    valid_base.each do |b|
      if @basebox == b.vagrantbase
        @url = b.url
        return true
      end
    end
    return false
  end

end