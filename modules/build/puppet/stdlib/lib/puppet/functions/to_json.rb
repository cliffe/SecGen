# Take a data structure and output it as JSON
#
# @example how to output JSON
#   # output json to a file
#     file { '/tmp/my.json':
#       ensure  => file,
#       content => to_json($myhash),
#     }
#
#
require 'json'

Puppet::Functions.create_function(:to_json) do
  dispatch :to_json do
    param 'Any', :data
  end

  def to_json(data)
    data.to_json
  end
end
