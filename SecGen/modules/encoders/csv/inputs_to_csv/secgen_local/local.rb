#!/usr/bin/ruby
require 'base64'
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class CSVEncoder < StringEncoder
  def initialize
    super
    self.module_name = 'CSV Encoder'
  end

  def encode_all()
    require 'csv'
    require 'json'

    csv_string = CSV.generate do |csv|
      strings_to_encode.each do |string_to_encode, count|
        row = []
        header = []
        JSON.parse(string_to_encode).each do |hash|
          header << hash[0]
          row << hash[1]
        end
        if count == 0
          csv << header
        end
        csv << row

      end

    end

    self.outputs << csv_string
  end
end

CSVEncoder.new.run
