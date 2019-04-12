class EncodingFunctions

  # Wrapper around force_encoding for readability
  def self.string_to_utf8(value)
    value.force_encoding('UTF-8')
  end

  # Recursively convert all hash values to UTF-8 encoding
  def self.hash_to_utf8(value)
    Hash[
        value.collect do |k, v|
          if v.respond_to?(:to_utf8)
            [k, v.to_utf8]
          elsif v.respond_to?(:force_encoding)
            [k, v.dup.force_encoding('UTF-8')]
          else
            [k, v]
          end
        end
    ]
  end

  # Recursively convert all array values to UTF-8 encoding
  def self.array_to_utf8(value)
    utf8 = []
    value.map {|element|
      if element.is_a? String
        utf8 << element.force_encoding('UTF-8')
      elsif element.is_a? Hash
        utf8 << EncodingFunctions::hash_to_utf8(element)
      elsif element.is_a? Array
        array_to_utf8(element)
      end
    }
    utf8
  end
end