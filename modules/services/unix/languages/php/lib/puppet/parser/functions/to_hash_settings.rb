
module Puppet::Parser::Functions
  newfunction(:to_hash_settings, :type => :rvalue, :doc => <<-EOS
This function converts a +{key => value}+ hash into a nested hash and can add an id to the outer key.
The optional id string as second parameter is prepended to the resource name.

*Examples:*

  to_hash_settings({'a' => 1, 'b' => 2})

Would return:
  {
    'a' => {'key' => 'a', 'value' => 1},
    'b' => {'key' => 'b', 'value' => 2}
  }

and:

  to_hash_settings({'a' => 1, 'b' => 2}, 'foo')

Would return:
  {
    'foo: a' => {'key' => 'a', 'value' => 1},
    'foo: b' => {'key' => 'b', 'value' => 2}
  }
EOS
  ) do |arguments|

    hash, id = arguments
    id = (id.nil? ? "" : "#{id}: ")

    raise(Puppet::ParseError, "to_hash_settings(): Requires hash to work with") unless hash.is_a?(Hash)

    return hash.reduce({}) do |acc, kv|
      acc[id + kv[0]] = { "key" => kv[0], "value" => kv[1] }
      acc
    end
  end
end
