module Puppet::Parser::Functions
  newfunction(:validate_re, :doc => <<-'ENDHEREDOC') do |args|
    Perform simple validation of a string against one or more regular
    expressions. The first argument of this function should be a string to
    test, and the second argument should be a stringified regular expression
    (without the // delimiters) or an array of regular expressions.  If none
    of the regular expressions match the string passed in, compilation will
    abort with a parse error.

    If a third argument is specified, this will be the error message raised and
    seen by the user.

    The following strings will validate against the regular expressions:

        validate_re('one', '^one$')
        validate_re('one', [ '^one', '^two' ])

    The following strings will fail to validate, causing compilation to abort:

        validate_re('one', [ '^two', '^three' ])

    A helpful error message can be returned like this:

        validate_re($::puppetversion, '^2.7', 'The $puppetversion fact value does not match 2.7')

    Note: Compilation will also abort, if the first argument is not a String. Always use
    quotes to force stringification:

        validate_re("${::operatingsystemmajrelease}", '^[57]$')

    ENDHEREDOC

    function_deprecation([:validate_re, 'This method is deprecated, please use the stdlib validate_legacy function, with Stdlib::Compat::Re. There is further documentation for validate_legacy function in the README.'])

    if (args.length < 2) or (args.length > 3) then
      raise Puppet::ParseError, "validate_re(): wrong number of arguments (#{args.length}; must be 2 or 3)"
    end

    raise Puppet::ParseError, "validate_re(): input needs to be a String, not a #{args[0].class}" unless args[0].is_a? String

    msg = args[2] || "validate_re(): #{args[0].inspect} does not match #{args[1].inspect}"

    # We're using a flattened array here because we can't call String#any? in
    # Ruby 1.9 like we can in Ruby 1.8
    raise Puppet::ParseError, msg unless [args[1]].flatten.any? do |re_str|
      args[0] =~ Regexp.compile(re_str)
    end

  end
end
