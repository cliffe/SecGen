module Puppet_X
  # Custom Elastic functions
  module Elastic
    # Certain Elasticsearch APIs return fields that are present in responses
    # but not present when sending API requests such as creation time, and so
    # on. When comparing desired settings and extant settings, only indicate
    # that a value differs from another when user-desired settings differ from
    # existing settings - we ignore keys that exist in the response that aren't
    # being explicitly controlled by Puppet.
    def self.asymmetric_compare(should_val, is_val)
      should_val.reduce(true) do |is_synced, (should_key, should_setting)|
        if is_val.key? should_key
          if is_val[should_key].is_a? Hash
            asymmetric_compare(should_setting, is_val[should_key])
          else
            is_synced && is_val[should_key] == should_setting
          end
        else
          is_synced && true
        end
      end
    end
  end # of Elastic
end # of Puppet_X
