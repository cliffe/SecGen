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