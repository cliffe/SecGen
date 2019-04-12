module Puppet::Parser::Functions
  newfunction(:validate_absolute_path, :doc => <<-'ENDHEREDOC') do |args|
    Validate the string represents an absolute path in the filesystem.  This function works
    for windows and unix style paths.

    The following values will pass:

        $my_path = 'C:/Program Files (x86)/Puppet Labs/Puppet'
        validate_absolute_path($my_path)
        $my_path2 = '/var/lib/puppet'
        validate_absolute_path($my_path2)
        $my_path3 = ['C:/Program Files (x86)/Puppet Labs/Puppet','C:/Program Files/Puppet Labs/Puppet']
        validate_absolute_path($my_path3)
        $my_path4 = ['/var/lib/puppet','/usr/share/puppet']
        validate_absolute_path($my_path4)

    The following values will fail, causing compilation to abort:

        validate_absolute_path(true)
        validate_absolute_path('../var/lib/puppet')
        validate_absolute_path('var/lib/puppet')
        validate_absolute_path([ 'var/lib/puppet', '/var/foo' ])
        validate_absolute_path([ '/var/lib/puppet', 'var/foo' ])
        $undefined = undef
        validate_absolute_path($undefined)

    ENDHEREDOC

    # The deprecation function was being called twice, as validate_absolute_path calls is_absolute_path. I have removed it from here so it only calls deprecation once within is_absolute_path.
    # function_deprecation([:validate_absolute_path, 'This method is deprecated, please use the stdlib validate_legacy function, with Stdlib::Compat::Absolute_path. There is further documentation for validate_legacy function in the README.'])

    require 'puppet/util'

    unless args.length > 0 then
      raise Puppet::ParseError, ("validate_absolute_path(): wrong number of arguments (#{args.length}; must be > 0)")
    end

    args.each do |arg|
      # put arg to candidate var to be able to replace it
      candidates = arg
      # if arg is just a string with a path to test, convert it to an array
      # to avoid test code duplication
      unless arg.is_a?(Array) then
        candidates = Array.new(1,arg)
      end
      # iterate over all paths within the candidates array
      candidates.each do |path|
        unless function_is_absolute_path([path])
          raise Puppet::ParseError, ("#{path.inspect} is not an absolute path.")
        end
      end
    end
  end
end
