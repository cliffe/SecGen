require 'getoptlong'
require_relative '../helpers/constants'
require 'base64'

# Inherited by local string generators
# stdout used to return value
# use Print.local to print status messages (formatted to stdout)

# A nice side-effect is that each of these modules is also an executable script

class StringGenerator
  require_relative '../helpers/print.rb'

  attr_accessor :module_name
  attr_accessor :has_base64_inputs
  attr_accessor :outputs
  attr_accessor :iterations

  # override this
  def initialize
    # default values
    self.module_name = 'Null generator'
    self.has_base64_inputs = false
    self.iterations = 1
    self.outputs = []
  end

  # override this
  def generate
    self.outputs << ''
  end

  def read_arguments
    # Get command line arguments
    Print.local 'Reading args from STDIN'
    if ARGV.size == 0
      begin
        args_array = []
        ARGF.each do |arg|
          arg.strip.split(' ').each do |split|
            args_array << split
          end
        end
        ARGV.unshift(*args_array)
      rescue
        # Do nothing...
      end
    end

    opts = get_options

    # process option arguments
    opts.each do |opt, arg|
      # Check if base64 decoding is required and set instance variable
      if opt == '--b64'
        self.has_base64_inputs = true
      end
      # Decode if required
      argument = self.has_base64_inputs ? Base64.strict_decode64(arg) : arg
      process_options(opt, argument)
    end
  end

  # Override this when using read_fact's in your module
  def get_options
    GetoptLong.new(*get_options_array)
  end

  def get_options_array
    [['--help', '-h', GetoptLong::NO_ARGUMENT],
     ['--b64', GetoptLong::OPTIONAL_ARGUMENT],
     ['--iterations', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  # Override this when using read_fact's in your module. Always call super first
  def process_options(opt, arg)
    unless option_is_valid(opt)
      Print.err "Argument not valid: #{arg}"
      usage
      exit
    end

    case opt
      when '--help'
        usage
      when '--b64'
        # do nothing
      when '--iterations'
        if not arg.to_i == 0
          self.iterations = arg.to_i
        else
          self.iterations = 1
        end
    end
  end

  def usage
    Print.err "Usage:
   #{$0} [--options]

   OPTIONS:
     --strings_to_encode [string]
     --iterations [Integer]
"
    exit
  end

  def run
    Print.local module_name

    read_arguments

    Print.local_verbose "Generating..."
    self.iterations.times do
      generate
    end

    # print the first 1000 chars to screen
    output = self.outputs.to_s
    length = output.length
    if length < 1000
      Print.local_verbose "Generated: #{output}..."
    else
      Print.local_verbose "Generated: #{output.to_s[0..1000]}..."
      Print.local_verbose "(Displaying 1000/#{length} length output)"
    end

    self.outputs = enforce_utf8(self.outputs)
    print_outputs
  end

  def enforce_utf8(values)
    values.map { |o| o.dup.force_encoding('UTF-8') }
  end

  def print_outputs
    puts base64_encode_outputs
  end

  def base64_encode_outputs
    self.outputs.map { |o| Base64.strict_encode64 o }
  end

  def option_is_valid(opt_to_check)
    arg_validity = false
    valid_arguments = get_options_array
    valid_arguments.each{ |valid_arg_array|
      valid_arg_array.each_with_index  { |valid_arg|
        if valid_arg == opt_to_check
          arg_validity = true
        end
      }
    }
    arg_validity
  end
end
