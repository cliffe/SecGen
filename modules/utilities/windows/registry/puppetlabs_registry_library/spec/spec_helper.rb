
dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(dir, 'lib')

require 'mocha'
require 'puppet'
require 'rspec'
require 'rspec-puppet'
require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.mock_with :mocha

  if File::ALT_SEPARATOR && RUBY_VERSION =~ /^1\./
    require 'win32console'
    c.output_stream = $stdout
    c.error_stream = $stderr
    c.formatters.each { |f| f.instance_variable_set(:@output, $stdout) }
  end

  c.expect_with :rspec do |e|
    e.syntax = [:should, :expect]
  end
end

# We need this because the RAL uses 'should' as a method.  This
# allows us the same behaviour but with a different method name.
class Object
  alias :must :should
end
