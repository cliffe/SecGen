#!/usr/bin/ruby
require_relative 'local_string_generator.rb'
require 'erb'
require 'fileutils'
require 'redcarpet'
require 'nokogiri'

class HackerbotConfigGenerator < StringGenerator
  attr_accessor :accounts
  attr_accessor :flags
  attr_accessor :root_password
  attr_accessor :html_rendered
  attr_accessor :html_TOC_rendered
  attr_accessor :title

  attr_accessor :local_dir
  attr_accessor :templates_path
  attr_accessor :config_template_path
  attr_accessor :html_template_path

  def initialize
    super
    self.module_name = 'Hackerbot Config Generator'
    self.title = ''
    self.accounts = []
    self.flags = []
    self.root_password = ''
    self.html_rendered = ''
    self.html_TOC_rendered = ''

    self.local_dir = File.expand_path('../../', __FILE__)
    self.templates_path = "#{self.local_dir}/templates/"
    self.config_template_path = "#{self.local_dir}/templates/integrity_lab.xml.erb"
    self.html_template_path = "#{self.local_dir}/templates/labsheet.html.erb"

  end

  def get_options_array
    super + [['--root_password', GetoptLong::REQUIRED_ARGUMENT],
             ['--accounts', GetoptLong::REQUIRED_ARGUMENT],
             ['--flags', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--root_password'
        self.root_password << arg;
      when '--accounts'
        self.accounts << arg;
      when '--flags'
        self.flags << arg;
    end
  end

  def generate_lab_sheet(xml_config)
    lab_sheet = ''
    begin
      doc = Nokogiri::XML(xml_config)
    rescue
      Print.err "Failed to process hackerbot config"
      exit
    end
    # remove xml namespaces for ease of processing
    doc.remove_namespaces!
    # for each element in the vulnerability
    hackerbot = doc.xpath("/hackerbot")
    name = hackerbot.xpath("name").first.content
    lab_sheet += hackerbot.xpath("tutorial_info/tutorial").first.content + "\n"

    doc.xpath("//attack").each_with_index do |attack, index|
      attack.xpath("tutorial").each do |tutorial_snippet|
        lab_sheet += tutorial_snippet.content + "\n"
      end

      lab_sheet += "#### #{name} Attack ##{index + 1}\n"
      lab_sheet += "Use what you have learned to complete the bot's challenge. You can skip the bot to here, by saying '**goto #{index + 1}**'\n\n"
      lab_sheet += "> #{name}: \"#{attack.xpath('prompt').first.content}\" \n\n"
      lab_sheet += "Do any necessary preparation, then when you are ready for the bot to complete the action/attack, ==say 'ready'==\n\n"
      if attack.xpath("quiz").size > 0
        lab_sheet += "There is a quiz to complete. Once Hackerbot asks you the question you can =='answer *YOURANSWER*'==\n\n"
      end
      lab_sheet += "Don't forget to ==save and submit any flags!==\n\n"
    end
    lab_sheet += hackerbot.xpath("tutorial_info/footer").first.content + "\n"

    lab_sheet
  end

  def generate

    # Print.debug self.accounts.to_s
    xml_template_out = ERB.new(File.read(self.config_template_path), 0, '<>-')
    xml_config = xml_template_out.result(self.get_binding)

    lab_sheet_markdown = generate_lab_sheet(xml_config)

    redcarpet = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(prettify:true, hard_wrap: true, with_toc_data: true), footnotes: true, fenced_code_blocks: true, no_intra_emphasis: true, autolink: true, highlight: true, lax_spacing: true, tables: true)
    self.html_rendered = redcarpet.render(lab_sheet_markdown).force_encoding('UTF-8')
    redcarpet_toc = Redcarpet::Markdown.new(Redcarpet::Render::HTML_TOC.new())
    self.html_TOC_rendered = redcarpet_toc.render(lab_sheet_markdown).force_encoding('UTF-8')
    html_template_out = ERB.new(File.read(self.html_template_path), 0, '<>-')
    html_out = html_template_out.result(self.get_binding)

    json = {'xml_config' => xml_config.force_encoding('UTF-8'), 'html_lab_sheet' => html_out.force_encoding('UTF-8')}.to_json.force_encoding('UTF-8')
    self.outputs << json.to_s
  end

  # Returns binding for erb files (access to variables in this classes scope)
  # @return binding
  def get_binding
    binding
  end
end
