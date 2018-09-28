#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_generator.rb'
require 'date'
require 'sqlite3'
require 'fileutils'

class ChromeHistoryFileGenerator < StringGenerator
  attr_accessor :number_of_generic_urls
  attr_accessor :generic_urls_start_time
  attr_accessor :generic_urls_end_time

  attr_accessor :number_of_cybercrime_urls
  attr_accessor :cybercrime_urls_start_time
  attr_accessor :cybercrime_urls_end_time

  def initialize
    super
    self.module_name = 'Chrome history file generator'
    # self.history_urls = ''
    self.number_of_generic_urls = ''
    self.generic_urls_start_time = ''
    self.generic_urls_end_time = ''

    self.number_of_cybercrime_urls = ''
    self.cybercrime_urls_start_time = ''
    self.cybercrime_urls_end_time = ''
  end

  def get_options_array
    super + [['--number_of_generic_urls', GetoptLong::REQUIRED_ARGUMENT],
             ['--generic_urls_start_time', GetoptLong::REQUIRED_ARGUMENT],
             ['--generic_urls_end_time', GetoptLong::REQUIRED_ARGUMENT],
             ['--number_of_cybercrime_urls', GetoptLong::REQUIRED_ARGUMENT],
             ['--cybercrime_urls_start_time', GetoptLong::REQUIRED_ARGUMENT],
             ['--cybercrime_urls_end_time', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--number_of_generic_urls'
        self.number_of_generic_urls << arg;
      when '--generic_urls_start_time'
        self.generic_urls_start_time << arg;
      when '--generic_urls_end_time'
        self.generic_urls_end_time << arg;
      when '--number_of_cybercrime_urls'
        self.number_of_cybercrime_urls << arg;
      when '--cybercrime_urls_start_time'
        self.cybercrime_urls_start_time << arg;
      when '--cybercrime_urls_end_time'
        self.cybercrime_urls_end_time << arg;
    end
  end


  def generate
    local_user = 'vagrant'
    chrome_user = 'Default'
    chrome_history_file_tmp_path = "#{FILE_TRANSFER_STORAGE_MODULE_DIR}/files/History"

    urls = Hash.new

    # self.number_of_generic_urls = 100
    # self.generic_urls_start_time = '3rd july 2013 15:16:20'
    # self.generic_urls_end_time = '5th june 2015 15:16:20'
    #
    # self.number_of_cybercrime_urls = 10
    # self.cybercrime_urls_start_time  = '4th july 2013 12:00:00'
    # self.cybercrime_urls_end_time = '4th july 2013 15:00:00'

    # Generic filler urls
    generic_urls = File.readlines("#{URLLISTS_DIR}/generic_urls").sample(self.number_of_generic_urls.to_i)

    # Crime url start
    cybercrime_urls = File.readlines("#{URLLISTS_DIR}/cybercrime_urls").sample(self.number_of_cybercrime_urls.to_i)

    generic_urls.each do |url|
      date_start = Time.parse(self.generic_urls_start_time)
      date_end = Time.parse(self.generic_urls_end_time)

      urls[url] = {
          :url => url,
          :title => url[/\/\/.*\//].gsub(/(\/)/,''),
          :visit_count => rand(0..100).to_i,
          :typed_count => rand(0..100).to_i,
          :last_visit_time => (date_start.to_f + rand * (date_end.to_f - date_start.to_f)).to_i,
          :hidden => '0',
          :favicon_id => '0'
      }
    end

    cybercrime_urls.each do |url|
      date_start = Time.parse(self.generic_urls_start_time)
      date_end = Time.parse(self.generic_urls_end_time)

      urls[url] = {
          :url => url,
          :title => url[/\/\/.*\//].gsub(/(\/)/,''),
          :visit_count => rand(0..100).to_i,
          :typed_count => rand(0..100).to_i,
          :last_visit_time => (date_start.to_f + rand * (date_end.to_f - date_start.to_f)).to_i,
          :hidden => '0',
          :favicon_id => '0'
      }
    end

    history_urls = Hash[urls.to_a.shuffle]

    FileUtils.cp("#{INTERNET_BROWSER_FILES_DIR}/chrome_history_file.source", chrome_history_file_tmp_path)

    database = SQLite3::Database.new( chrome_history_file_tmp_path ) do |db|
      history_urls.each_value do |details|
      db.execute(
            "INSERT INTO urls(url, title, visit_count, typed_count, last_visit_time, hidden, favicon_id)
VALUES ('#{details[:url]}', '#{details[:title]}', '#{details[:visit_count]}', '#{details[:typed_count]}', '#{details[:last_visit_time]}', '#{details[:hidden]}', '#{details[:favicon_id]}');"
      )
      end
    end

    self.outputs << Base64.strict_encode64(chrome_history_file_tmp_path).split(/[\\\/]/).last
  end
end

ChromeHistoryFileGenerator.new.run