# Take a data structure and output it as YAML
#
# @example how to output YAML
#   # output yaml to a file
#     file { '/tmp/my.yaml':
#       ensure  => file,
#       content => to_yaml($myhash),
#     }
#
#
require 'yaml'

Puppet::Functions.create_function(:to_yaml) do
  dispatch :to_yaml do
    param 'Any', :data
  end

  def to_yaml(data)
    data.to_yaml
  end
end
