# When given a hash this function strips out all blank entries.
module Puppet::Parser::Functions
  newfunction(:mysql_strip_hash, type: :rvalue, arity: 1, doc: <<-EOS
  TEMPORARY FUNCTION: EXPIRES 2014-03-10
  When given a hash this function strips out all blank entries.
EOS
             ) do |args|

    hash = args[0]
    unless hash.is_a?(Hash)
      raise(Puppet::ParseError, _('mysql_strip_hash(): Requires a hash to work.'))
    end

    # Filter out all the top level blanks.
    hash.reject { |_k, v| v == '' }.each do |_k, v|
      v.reject! { |_ki, vi| vi == '' } if v.is_a?(Hash)
    end
  end
end
