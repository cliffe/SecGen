# Take a data structure and output it as pretty JSON
#
# @example how to output pretty JSON
#   # output pretty json to a file
#     file { '/tmp/my.json':
#       ensure  => file,
#       content => to_json_pretty($myhash),
#     }
#
# @example how to output pretty JSON skipping over keys with undef values
#   # output pretty JSON to a file skipping over undef values
#     file { '/tmp/my.json':
#       ensure  => file,
#       content => to_json_pretty({
#         param_one => 'value',
#         param_two => undef,
#       }),
#     }
#
require 'json'

Puppet::Functions.create_function(:to_json_pretty) do
  dispatch :to_json_pretty do
    param 'Variant[Hash, Array]', :data
    optional_param 'Boolean', :skip_undef
  end

  def to_json_pretty(data, skip_undef = false)
    if skip_undef
      if data.is_a? Array
        data = data.reject { |value| value.nil? }
      elsif data.is_a? Hash
        data = data.reject { |_, value| value.nil? }
      end
    end
    JSON.pretty_generate(data) << "\n"
  end
end
