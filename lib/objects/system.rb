class System
  # can access from outside of class
  attr_accessor :attributes

  #initalizes system variables
  def initialize(id, os, basebox, url, vulns=[], networks=[], services=[], sites=[])
    @attributes = {
        :id => id,
        :os => os,
        :basebox => basebox,
        :url => url,
        :vulns => vulns,
        :networks => networks,
        :services => services,
        :sites => sites
    }

  end

  def is_valid_base
    valid_base = Configuration.bases

    valid_base.each do |b|
      if @attributes[:basebox] == b.attributes[:vagrantbase]
        @attributes[:url] = b.attributes[:url]
        return true
      end
    end
    return false
  end

end