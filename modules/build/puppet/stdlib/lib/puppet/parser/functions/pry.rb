#
# pry.rb
#

module Puppet::Parser::Functions
  newfunction(:pry, :type => :statement, :doc => <<-EOS
This function invokes a pry debugging session in the current scope object. This is useful for debugging manifest code at specific points during a compilation.

*Examples:*

    pry()
    EOS
  ) do |arguments|
    begin
      require 'pry'
    rescue LoadError
      raise(Puppet::Error, "pry(): Requires the 'pry' rubygem to use, but it was not found")
    end
    #
    ## Run `catalog` to see the contents currently compiling catalog
    ## Run `cd catalog` and `ls` to see catalog methods and instance variables
    ## Run `@resource_table` to see the current catalog resource table
    #
    if $stdout.isatty
      binding.pry # rubocop:disable Lint/Debugger
    else
      Puppet.warning 'pry(): cowardly refusing to start the debugger on a daemonized master'
    end
  end
end
