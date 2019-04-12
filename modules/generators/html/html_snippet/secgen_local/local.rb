#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class HTMLSnippetGenerator < StringEncoder
  attr_accessor :heading
  attr_accessor :paragraphs

  def initialize
    super
    self.module_name = 'HTML Snippet Generator'
    self.heading = ''
    self.paragraphs = []
  end

  def encode_all
    # wrap heading in <h3> tags
    heading = "<h3>#{self.heading}</h3>"

    # wrap paragraphs in <p> tags
    wrapped_paragraphs = ""
    self.paragraphs.each { |paragraph|
      wrapped_paragraphs << "<p>#{paragraph}</p>\n"
    }

    # join the above and return the snippet
    snippet = "#{heading}\n\n#{wrapped_paragraphs}"
    self.outputs << snippet
  end

  def get_options_array
    super + [['--heading', GetoptLong::REQUIRED_ARGUMENT],
             ['--paragraphs', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--heading'
        self.heading << arg;
      when '--paragraphs'
        self.paragraphs << arg;
    end
  end


  def encoding_print_string
    'heading: ' + self.heading.to_s + print_string_padding +
    'paragraphs: ' +self.paragraphs.to_s
  end
end

HTMLSnippetGenerator.new.run