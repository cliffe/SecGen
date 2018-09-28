#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_generator.rb'
require 'time'
require 'json'

class UrlGenerator < StringGenerator
  attr_accessor :number_of_generic_urls
  attr_accessor :generic_urls_start_time
  attr_accessor :generic_urls_end_time

  def initialize
    super
    self.module_name = 'Url generator'
    # self.number_of_generic_urls = ''
    # self.generic_urls_start_time = ''
    # self.generic_urls_end_time = ''
    # self.number_of_cybercrime_urls = ''
    # self.cybercrime_urls_start_time = ''
  end

  def generate
    urls = Hash.new

    self.number_of_generic_urls = 10
    self.generic_urls_start_time = '3rd july 2013 15:16:20'
    self.generic_urls_end_time = '5rd june 2015 15:16:20'

    # Generic filler urls
    generic_urls = File.readlines("#{URLLISTS_DIR}/generic_urls").sample(self.number_of_generic_urls.to_int)

    # Crime url start
    # cybercrime_urls = File.readlines("#{URLLISTS_DIR}/cybercrime_urls").sample(self.number_of_cybercrime_urls).chomp

    generic_urls.each do |url|
      date_start = Time.parse(self.generic_urls_start_time)
      date_end = Time.parse(self.generic_urls_end_time)

      urls[url] = {
          :url => url,
          :title => url[/\/\/.*\//].gsub(/(\/)/),
          :visit_count => rand,
          :typed_count => rand,
          :last_visit_time => date_start.to_f + rand * (date_end.to_f - date_start.to_f),
          :hidden => '0',
          :favicon_id => '0'
      }
    end

    # self.outputs << Base64.strict_encode64(urls.to_s)
    self.outputs << Base64.encode64(urls)
  end
end

UrlGenerator.new.run