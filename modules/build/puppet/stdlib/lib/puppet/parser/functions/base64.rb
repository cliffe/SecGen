#  Please note: This function is an implementation of a Ruby class and as such may not be entirely UTF8 compatible. To ensure compatibility please use this function with Ruby 2.4.0 or greater - https://bugs.ruby-lang.org/issues/10085.
module Puppet::Parser::Functions
  newfunction(:base64, :type => :rvalue, :doc => <<-'DOC') do |args|
    Base64 encode or decode a string based on the command and the string submitted

    Usage:

      $encodestring = base64('encode', 'thestring')
      $decodestring = base64('decode', 'dGhlc3RyaW5n')

      # explicitly define encode/decode method: default, strict, urlsafe
      $method = 'default'
      $encodestring = base64('encode', 'thestring', $method)
      $decodestring = base64('decode', 'dGhlc3RyaW5n', $method)

    DOC

    require 'base64'

    raise Puppet::ParseError, "base64(): Wrong number of arguments (#{args.length}; must be >= 2)" unless args.length >= 2

    actions = %w[encode decode]

    unless actions.include?(args[0])
      raise Puppet::ParseError, "base64(): the first argument must be one of 'encode' or 'decode'"
    end

    unless args[1].is_a?(String)
      raise Puppet::ParseError, 'base64(): the second argument must be a string to base64'
    end

    method = %w[default strict urlsafe]

    chosen_method = if args.length <= 2
                      'default'
                    else
                      args[2]
                    end

    unless method.include?(chosen_method)
      raise Puppet::ParseError, "base64(): the third argument must be one of 'default', 'strict', or 'urlsafe'"
    end

    case args[0]
    when 'encode'
      case chosen_method
      when 'default'
        result = Base64.encode64(args[1])
      when 'strict'
        result = Base64.strict_encode64(args[1])
      when 'urlsafe'
        result = Base64.urlsafe_encode64(args[1])
      end
    when 'decode'
      case chosen_method
      when 'default'
        result = Base64.decode64(args[1])
      when 'strict'
        result = Base64.strict_decode64(args[1])
      when 'urlsafe'
        result = Base64.urlsafe_decode64(args[1])
      end
    end

    return result
  end
end
