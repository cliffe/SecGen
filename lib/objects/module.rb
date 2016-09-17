require_relative '../helpers/constants.rb'

class Module
  #Vulnerability attributes hash
  attr_accessor :module_path # vulnerabilities/unix/ftp/vsftp_234_backdoor
  attr_accessor :module_type # vulnerability|service|utility
  attr_accessor :attributes  # attributes are hashes that contain arrays of values
  # Each attribute is stored in a hash containing an array of values (because elements such as author can repeat).
  # Module *selectors*, store filters in the attributes hash.
  # XML validity ensures valid and complete information.

  attr_accessor :conflicts
  attr_accessor :requires
  attr_accessor :puppet_file
  attr_accessor :puppet_other_path

  # @param [Object] module_type: such as 'vulnerability', 'base', 'service', 'network'
  def initialize(module_type)
    self.module_type = module_type
    self.conflicts = []
    self.requires = []
    self.attributes = {}
    # self.attributes['module_type'] = module_type # add as an attribute for filtering
  end

  # @return [Object] a string for console output
  def to_s
    (<<-END)
    #{module_type}: #{module_path}
      attributes: #{attributes.inspect}
      conflicts: #{conflicts.inspect}
      requires: #{requires.inspect}
      puppet file: #{puppet_file}
      puppet path: #{puppet_other_path}
    END
  end

  # @return [Object] a string for Vagrant/Ruby file comments
  def to_s_comment
    (<<-END)
    # #{module_type}: #{module_path}
    #   attributes: #{attributes.inspect}
    #   conflicts: #{conflicts.inspect}
    #   requires: #{requires.inspect}
    END
  end

  # @return [Object] the leaf directory (last part of the module path)
  def module_path_end
    match = module_path.match(/.*?([^\/]*)$/i)
    match.captures[0]
  end

  # @return [Object] the module path with _ rather than / for use as a variable name
  def module_path_name
    module_path_name = module_path.clone
    module_path_name.gsub!('/','_')
  end

  # @return [Object] a list of attributes that can be used to re-select the same modules
  def attributes_for_scenario_output
    attr_flattened = {}

    attributes.each do |key, array|
      unless "#{key}" == 'module_type' || "#{key}" == 'conflict'
        # creates a valid regexp that can match the original module
        attr_flattened["#{key}"] = Regexp.escape(array.join('~~~')).gsub(/\n\w*/, '.*').gsub(/\\ /, ' ').gsub(/~~~/, '|')
      end
    end

    attr_flattened
  end

  # A one directional test for conflicts
  # Returns whether this module specifies it conflicts with the other_module.
  # Each conflict can have multiple conditions which must all be met for this
  # to be considered a conflict. However, only one conflict needs to be satisfied.
  # @param [Object] other_module to compare with
  # @return [Object] boolean
  def conflicts_with(other_module)
    # for each conflict
    self.conflicts.each do |conflict|
      if other_module.matches_attributes_requirement(conflict)
        return true
      end
    end
    false
  end

  def matches_attributes_requirement(required)
    all_conditions_met = true
    required.keys.each do |require_key|
      key_matched = false

      if self.attributes["#{require_key}"] != nil
        # for each corresponding value in the previously selected module
        self.attributes["#{require_key}"].each do |value|
          # for each value in the required list
          required["#{require_key}"].each do |required_value|
            if Regexp.new(required_value).match(value)
              key_matched = true
            end
          end
        end
      end
      # any failure to match
      unless key_matched
        return false
      end
    end
    all_conditions_met
  end

  def printable_name
    "#{self.attributes['name'][0]} (#{self.module_path})"
  end

end
