require 'getoptlong'
require_relative '../helpers/constants'
require_relative './local_encoding_functions.rb'
require 'json'
require 'base64'

# Inherited by local string encoders
# stdout used to return value
# use Print.local to print status messages (formatted to stdout)

# A nice side-effect is that each of these modules is also an executable script

class StringEncoder
  require_relative '../helpers/print.rb'

  attr_accessor :module_name
  attr_accessor :strings_to_encode
  attr_accessor :has_base64_inputs
  attr_accessor :outputs

  # override this
  def initialize
    # default values
    self.strings_to_encode = []
    self.module_name = 'Null encoder'
    self.has_base64_inputs = false
    self.outputs = []
  end

  # override this for per-item encoding
  def encode (str)
    str
  end

  # override this for array processing / aggregation
  def encode_all
    self.strings_to_encode.each do |value|
      self.outputs << encode(value)
    end
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

  def get_options
    GetoptLong.new(*get_options_array)
  end

  # Override this when using read_fact's in your module.
  # Make sure you include the defaults by merging the 2D arrays using: super + [[a,b],[c,d]...]
  def get_options_array
    [['--help', '-h', GetoptLong::NO_ARGUMENT],
     ['--b64', GetoptLong::OPTIONAL_ARGUMENT],
     ['--strings_to_encode', '-s', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  # Override this when using read_fact's in your module. Always call super first.
  def process_options(opt, arg)
    unless option_is_valid(opt)
      Print.err "Argument not valid: #{arg}"
      usage
      exit
    end

    case opt
      when '--help'
        usage
      when '--strings_to_encode'
        self.strings_to_encode << arg;
      when '--b64'
        # do nothing
    end
  end

  def usage
    Print.err "Usage:
   #{$0} [--options]

   OPTIONS:"
    valid_options = get_options_array
    valid_options.each { |option_array|
       option = option_array[0...-1].join(' ')
       Print.err((' '*5) + option)
     }
    exit
  end

  def run
    Print.local module_name

    read_arguments
    enforce_utf8

    Print.local_verbose "Encoding '#{encoding_print_string}'"
    encode_all

    # print the first 700 chars to screen
    output = self.outputs.to_s
    length = output.length
    if length < 1000
      Print.local_verbose "Encoded: #{output}..."
    else
      Print.local_verbose "Encoded: #{output.to_s[0..1000]}..."
      Print.local_verbose "(Displaying 1000/#{length} length output)"
    end

    enforce_utf8
    print_outputs if has_base64_inputs
  end

  # Encode local instance variables as UTF-8
  def enforce_utf8
    self.instance_variables.each do |iv|
      iv_value = self.instance_variable_get(iv)
      if iv_value.is_a? Array
        self.instance_variable_set(iv, EncodingFunctions::array_to_utf8(iv_value))
      elsif iv_value.is_a? Hash
        self.instance_variable_set(iv, EncodingFunctions::hash_to_utf8(iv_value))
      elsif iv_value.is_a? String
        self.instance_variable_set(iv, EncodingFunctions::string_to_utf8(iv_value))
      end
    end
  end

  def print_outputs
    puts base64_encode_outputs
  end

  def base64_encode_outputs
    self.outputs.map { |o| Base64.strict_encode64 o }
  end

  def encoding_print_string
    self.strings_to_encode.to_s
  end

  def print_string_padding
    "\n" + (' ' * 11)
  end

  def option_is_valid(opt_to_check)
    option_validity = false
    valid_options = get_options_array

    valid_options.each{ |valid_opt_array|
      valid_opt_array.each_with_index  { |valid_opt|
        if valid_opt == opt_to_check
          option_validity = true
        end
      }
    }

    option_validity
  end
end
