# Top-level Puppet functions
module Puppet::Parser::Functions
  newfunction(
    :plugin_dir,
    :type => :rvalue,
    :doc => <<-EOS
    Extracts the end plugin directory of the name

    @return String
    EOS
  ) do |arguments|
    if arguments.empty?
      raise(Puppet::ParseError, 'plugin_dir(): No arguments given')
    elsif arguments.size > 2
      raise(Puppet::ParseError, "plugin_dir(): Too many arguments given (#{arguments.size})")
    else

      unless arguments[0].is_a?(String)
        raise(Puppet::ParseError, 'plugin_dir(): Requires string as first argument')
      end

      plugin_name = arguments[0]
      items = plugin_name.split('/')

      return items[0] if items.count == 1

      plugin = items[1]
      endname = if plugin.include?('-') # example elasticsearch-head
                  if plugin.start_with?('elasticsearch-')
                    plugin.gsub('elasticsearch-', '')
                  elsif plugin.start_with?('es-')
                    plugin.gsub('es-', '')
                  else
                    plugin
                  end
                else
                  plugin
                end

      return endname
    end
  end
end
