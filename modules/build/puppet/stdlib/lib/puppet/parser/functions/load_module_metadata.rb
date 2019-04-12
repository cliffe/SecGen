module Puppet::Parser::Functions
  newfunction(:load_module_metadata, :type => :rvalue, :doc => <<-EOT
  EOT
  ) do |args|
    raise(Puppet::ParseError, "load_module_metadata(): Wrong number of arguments, expects one or two") unless [1,2].include?(args.size)
    mod = args[0]
    allow_empty_metadata = args[1]
    module_path = function_get_module_path([mod])
    metadata_json = File.join(module_path, 'metadata.json')

    metadata_exists = File.exists?(metadata_json)
    if metadata_exists
      metadata = PSON.load(File.read(metadata_json))
    else
      if allow_empty_metadata
        metadata = {}
      else
        raise(Puppet::ParseError, "load_module_metadata(): No metadata.json file for module #{mod}")
      end
    end

    return metadata
  end
end
