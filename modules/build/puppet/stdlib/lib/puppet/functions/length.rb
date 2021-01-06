# A function to eventually replace the old size() function for stdlib - The original size function did not handle Puppets new type capabilities, so this function is a Puppet 4 compatible solution.
Puppet::Functions.create_function(:length) do
  dispatch :length do
    param 'Variant[String,Array,Hash]', :value
  end
  def length(value)
    if value.is_a?(String)
      result = value.length
    elsif value.is_a?(Array) || value.is_a?(Hash)
      result = value.size
    end
    result
  end
end
