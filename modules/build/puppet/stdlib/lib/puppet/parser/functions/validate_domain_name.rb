#
# validate_domain_name.rb
#
module Puppet::Parser::Functions
  newfunction(:validate_domain_name, :doc => <<-DOC
    Validate that all values passed are syntactically correct domain names.
    Fail compilation if any value fails this check.

    The following values will pass:

        $my_domain_name = 'server.domain.tld'
        validate_domain_name($my_domain_name)
        validate_domain_name('domain.tld', 'puppet.com', $my_domain_name)

    The following values will fail, causing compilation to abort:

        validate_domain_name(1)
        validate_domain_name(true)
        validate_domain_name('invalid domain')
        validate_domain_name('-foo.example.com')
        validate_domain_name('www.example.2com')

    DOC
             ) do |args|

    rescuable_exceptions = [ArgumentError]

    if args.empty?
      raise Puppet::ParseError, "validate_domain_name(): wrong number of arguments (#{args.length}; must be > 0)"
    end

    args.each do |arg|
      raise Puppet::ParseError, "#{arg.inspect} is not a string." unless arg.is_a?(String)

      begin
        raise Puppet::ParseError, "#{arg.inspect} is not a syntactically correct domain name" unless function_is_domain_name([arg])
      rescue *rescuable_exceptions
        raise Puppet::ParseError, "#{arg.inspect} is not a syntactically correct domain name"
      end
    end
  end
end
