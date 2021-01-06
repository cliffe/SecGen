# Digs into the facts hash using dot-notation
#
# Example usage:
#
#     fact('osfamily')
#     fact('os.architecture')
#
# Array indexing:
#
#     fact('mountpoints."/dev".options.1')
#
# Fact containing a "." in the name:
#
#     fact('vmware."VRA.version"')
#
Puppet::Functions.create_function(:fact) do
  dispatch :fact do
    param 'String', :fact_name
  end

  def to_dot_syntax(array_path)
    array_path.map { |string|
      string.include?('.') ? %("#{string}") : string
    }.join('.')
  end

  def fact(fact_name)
    facts = closure_scope['facts']

    # Transform the dot-notation string into an array of paths to walk. Make
    # sure to correctly extract double-quoted values containing dots as single
    # elements in the path.
    path = fact_name.scan(%r{([^."]+)|(?:")([^"]+)(?:")}).map { |x| x.compact.first }

    walked_path = []
    path.reduce(facts) do |d, k|
      return nil if d.nil? || k.nil?

      if d.is_a?(Array)
        begin
          result = d[Integer(k)]
        rescue ArgumentError => e # rubocop:disable Lint/UselessAssignment : Causes errors if assigment is removed.
          Puppet.warning("fact request for #{fact_name} returning nil: '#{to_dot_syntax(walked_path)}' is an array; cannot index to '#{k}'")
          result = nil
        end
      elsif d.is_a?(Hash)
        result = d[k]
      else
        Puppet.warning("fact request for #{fact_name} returning nil: '#{to_dot_syntax(walked_path)}' is not a collection; cannot walk to '#{k}'")
        result = nil
      end

      walked_path << k
      result
    end
  end
end
