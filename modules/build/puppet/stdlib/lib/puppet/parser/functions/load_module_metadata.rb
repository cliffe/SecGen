#
# load_module_metadata.rb
#
module Puppet::Parser::Functions
  newfunction(:load_module_metadata, :type => :rvalue, :doc => <<-DOC
    This function loads the metadata of a given module.
  DOC
             ) do |args|
    raise(Puppet::ParseError, 'load_module_metadata(): Wrong number of arguments, expects one or two') unless [1, 2].include?(args.size)
    mod = args[0]
    allow_empty_metadata = args[1]
    module_path = function_get_module_path([mod])
    metadata_json = File.join(module_path, 'metadata.json')

    metadata_exists = File.exists?(metadata_json) # rubocop:disable Lint/DeprecatedClassMethods : Changing to .exist? breaks the code
    if metadata_exists
      metadata = PSON.load(File.read(metadata_json))
    else
      metadata = {}
      raise(Puppet::ParseError, "load_module_metadata(): No metadata.json file for module #{mod}") unless allow_empty_metadata
    end

    return metadata
  end
end
