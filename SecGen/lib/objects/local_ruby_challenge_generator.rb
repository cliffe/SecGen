#!/usr/bin/ruby

require_relative 'local_script_challenge_generator.rb'
class RubyChallengeGenerator < ScriptChallengeGenerator

  def initialize
    super
    self.module_name = 'Ruby Example Script Generator'
  end

  def pre_challenge_setup
    "flag_path = ''
     if ARGV[0] and File.directory? ARGV[0]
       flag_path = ARGV.shift
       if flag_path[-1] != '/'
         flag_path += '/'
       end
     end
     flag_path += 'flag'\n"
  end

  def interpreter_path
    '/usr/bin/ruby'
  end

end