#require 'ruby-prof'
#RubyProf.start

IDEAL_CONSOLE_WIDTH = 72
def horizontal_rule(width = 5)
  '=' * [width, IDEAL_CONSOLE_WIDTH].min
end

require 'puppetlabs_spec_helper/module_spec_helper'

# require dependencies
gems = [
  #'minitest/autorun', # http://docs.seattlerb.org/minitest/
  #'minitest/unit', # https://github.com/freerange/mocha#bundler
  'mocha', # http://gofreerange.com/mocha/docs/Mocha/Configuration.html
  'puppet',
]
begin
  gems.each {|gem| require gem}
rescue => e
  # http://goo.gl/r3nFG
  # emphasize dependency failures in case a task spews lots of output
  warn horizontal_rule(e.message.length)
  warn e.class
  warn e.message
  warn horizontal_rule(e.message.length)
  exit(1)
end

RSpec.configure do |c|
  # set the environment variable before files are loaded, otherwise it is too late
  ENV['ChocolateyInstall'] = 'c:\blah'

  # https://www.relishapp.com/rspec/rspec-core/v/2-12/docs/mock-framework-integration/mock-with-mocha!
  c.mock_framework = :mocha
  # see output for all failures
  c.fail_fast = false
  c.expect_with :rspec do |e|
    e.syntax = [:should, :expect]
  end
  c.raise_errors_for_deprecations!

  c.after :suite do
    #result = RubyProf.stop
    # Print a flat profile to text
    #printer = RubyProf::FlatPrinter.new(result)
    #printer.print(STDOUT)
  end
end

# We need this because the RAL uses 'should' as a method.  This
# allows us the same behaviour but with a different method name.
class Object
  alias :must :should
  alias :must_not :should_not
end
