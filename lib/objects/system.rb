class System
  # System attributes hash
  attr_accessor :attributes

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

  # Checks to see if the selected base is a valid basebox and is in the vagrant file
  # @return [Boolean] Is the basebox valid
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