#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_generator.rb'

class XSSBlacklistGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'XSS blacklist Generator'
  end

  def generate
    # 53,721,360 different possibilities

    blacklist_file = File.readlines("#{WORDLISTS_DIR}/xss_blacklist")

    blacklist = []
    $i = 0
    $num = 6

    while $i < $num  do
       blacklist[$i] = blacklist_file.sample
       $i +=1
    end

    if blacklist[1] == blacklist[0]
      blacklist[1] = blacklist_file.sample
    end

    until blacklist[2] != blacklist[0] && blacklist[2] != blacklist[1] do
      blacklist[2] = blacklist_file.sample
    end

    until blacklist[3] != blacklist[0] && blacklist[3] != blacklist[1] && blacklist[3] != blacklist[2] do
      blacklist[3] = blacklist_file.sample
    end

    until blacklist[4] != blacklist[0] && blacklist[4] != blacklist[1] && blacklist[4] != blacklist[2] && blacklist[4] != blacklist[3] do
      blacklist[4] = blacklist_file.sample
    end

    until blacklist[5] != blacklist[0] && blacklist[5] != blacklist[1] && blacklist[5] != blacklist[2] && blacklist[5] != blacklist[3] && blacklist[5] != blacklist[4] do
      blacklist[5] = blacklist_file.sample
    end

    blacklist_o = blacklist[0].rstrip() + ',' + blacklist[1].rstrip() + ',' +  blacklist[2].rstrip() + ',' +  blacklist[3].rstrip() + ',' +  blacklist[4].rstrip() + ',' +  blacklist[5].rstrip()

    self.outputs << blacklist_o
  end
end

XSSBlacklistGenerator.new.run
