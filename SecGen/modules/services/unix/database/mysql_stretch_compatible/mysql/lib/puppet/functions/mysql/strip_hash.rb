# @summary
#   When given a hash this function strips out all blank entries.
#
Puppet::Functions.create_function(:'mysql::strip_hash') do
  # @param hash
  #   Hash to be stripped
  #
  dispatch :strip_hash do
    required_param 'Hash', :hash
    return_type 'Hash'
  end

  def strip_hash(hash)
    # Filter out all the top level blanks.
    hash.reject { |_k, v| v == '' }.each do |_k, v|
      v.reject! { |_ki, vi| vi == '' } if v.is_a?(Hash)
    end
  end
end
