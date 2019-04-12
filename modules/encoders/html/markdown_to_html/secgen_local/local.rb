#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'redcarpet'

class MarkdownToHtml < StringEncoder
  def initialize
    super
    self.module_name = 'Markdown to HTML Encoder'
  end

  def encode_all
    redcarpet = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(render_options = {}), extensions = {})
    markdown = redcarpet.render(self.strings_to_encode[0])
    self.outputs << markdown.force_encoding('UTF-8')
  end
end

MarkdownToHtml.new.run