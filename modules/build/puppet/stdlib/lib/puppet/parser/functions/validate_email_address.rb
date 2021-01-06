#
# validate_email_address.rb
#
module Puppet::Parser::Functions
  newfunction(:validate_email_address, :doc => <<-DOC
    Validate that all values passed are valid email addresses.
    Fail compilation if any value fails this check.
    The following values will pass:
    $my_email = "waldo@gmail.com"
    validate_email_address($my_email)
    validate_email_address("bob@gmail.com", "alice@gmail.com", $my_email)

    The following values will fail, causing compilation to abort:
    $some_array = [ 'bad_email@/d/efdf.com' ]
    validate_email_address($some_array)
    DOC
             ) do |args|
    rescuable_exceptions = [ArgumentError]

    if args.empty?
      raise Puppet::ParseError, "validate_email_address(): wrong number of arguments (#{args.length}; must be > 0)"
    end

    args.each do |arg|
      raise Puppet::ParseError, "#{arg.inspect} is not a string." unless arg.is_a?(String)

      begin
        raise Puppet::ParseError, "#{arg.inspect} is not a valid email address" unless function_is_email_address([arg])
      rescue *rescuable_exceptions
        raise Puppet::ParseError, "#{arg.inspect} is not a valid email address"
      end
    end
  end
end
