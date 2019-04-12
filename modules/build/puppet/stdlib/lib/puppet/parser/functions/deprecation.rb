module Puppet::Parser::Functions
  newfunction(:deprecation, :doc => <<-EOS
  Function to print deprecation warnings (this is the 3.X version of it), The uniqueness key - can appear once. The msg is the message text including any positional information that is formatted by the user/caller of the method.).
EOS
  ) do |arguments|

    raise(Puppet::ParseError, "deprecation: Wrong number of arguments given (#{arguments.size} for 2)") unless arguments.size == 2

    key = arguments[0]
    message = arguments[1]

    if ENV['STDLIB_LOG_DEPRECATIONS'] == "true"
      warning("deprecation. #{key}. #{message}")
    end
  end
end
