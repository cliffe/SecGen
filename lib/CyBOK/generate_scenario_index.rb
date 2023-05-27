require 'erb'
require 'nori'
require 'youtube_images'
require 'dig-deep'
require 'getoptlong'
require 'nokogiri/class_resolver'

# if you want to regenerate the indexes you need to install these additional gems:
# gem 'youtube_images'
# gem 'dig-deep'

require_relative '../helpers/print.rb'
require_relative '../helpers/constants.rb'

scenarios_dir = "scenarios/labs"
scenario_index_out = "#{ROOT_DIR}/README-CyBOK-Scenarios-Indexed.md"
output_video_index = true
scenario_type = "lab"

def usage
  Print.std "Usage:
   #{$0} [--options]

   OPTIONS:
   --lab
   --ctf
"
  exit
end
# Get command line arguments
opts = GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--lab', '-l', GetoptLong::NO_ARGUMENT],
    ['--ctf', '-c', GetoptLong::NO_ARGUMENT],

)
# process option arguments
opts.each do |opt, arg|
  case opt
  # Main options
  when '--help'
    usage
  when '--lab'
    scenarios_dir = "scenarios/labs"
    scenario_index_out = "#{ROOT_DIR}/README-CyBOK-Scenarios-Indexed.md"
    output_video_index = true
    scenario_type = "practical lab"
  when '--ctf'
    scenarios_dir = "scenarios/ctf"
    scenario_index_out = "#{ROOT_DIR}/README-CyBOK-CTF-Scenarios-Indexed.md"
    output_video_index = false
    scenario_type = "CTF"
  else
    Print.err "Argument not valid: #{arg}"
    usage
    exit 1
  end
end


Print.std "Reading scenarios! ***************************"
scenarios = []
# Get a list of all the scenarios
Dir.chdir("#{ROOT_DIR}/#{scenarios_dir}") do
  scenarios = Dir["**/*.xml"].sort
end

# read in the contents of the scenarios

@ka_hash = {}
@ka_video_hash = {}
@ka_topic_hash = {}

KA_TOPIC_SCENARIOS_HASH = Hash.new { |h, k| h[k] = h.dup.clear }
SCENARIOS_HASH = {}
SCENARIOS_FULL_HASH = {}
KA_TOPIC_VIDEO_HASH = Hash.new { |h, k| h[k] = h.dup.clear }
VIDEO_HASH = {}

CyBOK_ACRONYMS = {
  "AAA" => "Authentication, Authorisation &amp; Accountability",
  "AB" => "Adversarial Behaviours",
  "AC" => "Applied Cryptography",
  "C" => "Cryptography",
  "CPS" => "Cyber-Physical Systems Security",
  "DSS" => "Distributed Systems Security",
  "F" => "Forensics",
  "HF" => "Human Factors",
  "HS" => "Hardware Security",
  "LR" => "Law &amp; Regulation",
  "MAT" => "Malware &amp; Attack Technology",
  "NS" => "Network Security",
  "OSV" => "Operating Systems &amp; Virtualisation",
  "PLT" => "Physical Layer &amp; Telecommunications Security",
  "POR" => "Privacy &amp; Online Rights",
  "RMG" => "Risk Management &amp; Governance",
  "SOIM" => "Security Operations &amp; Incident Management",
  "SS" => "Software Security",
  "SSL" => "Secure Software Lifecycle",
  "WAM" => "Web &amp; Mobile Security",
}

parser = Nori.new()

scenarios.each { |scenario|
  next if scenario.start_with?("examples")
  Print.verbose "Reading #{scenario}"

  scenario_hash = parser.parse(File.read("#{ROOT_DIR}/#{scenarios_dir}/#{scenario}"))
  if scenario_hash && scenario_hash['scenario']
    (SCENARIOS_FULL_HASH[scenario] ||= []) << scenario_hash['scenario']
    if (scenario_hash['scenario']['CyBOK'].kind_of?(Array))
      scenario_hash['scenario']['CyBOK'].each {|cybok_entry|
        ka = cybok_entry['@KA']
        (@ka_hash[ka] ||= []) << scenario
        topic = cybok_entry['@topic']
        (@ka_topic_hash["#{ka} #{topic}"] ||= []) << scenario
        KA_TOPIC_SCENARIOS_HASH[ka][topic][scenario] = "-"
        (SCENARIOS_HASH[scenario] ||= []) << cybok_entry
      }
    elsif (scenario_hash['scenario']['CyBOK'])
      # KA_HASH[scenario] << scenario
      ka = scenario_hash['scenario']['CyBOK']['@KA']
      (@ka_hash[ka] ||= []) << scenario
      topic = scenario_hash['scenario']['CyBOK']['@topic']
      (@ka_topic_hash["#{ka} #{topic}"] ||= []) << scenario
      KA_TOPIC_SCENARIOS_HASH[ka][topic][scenario] = "-"
      # SCENARIOS_HASH[scenario] = scenario_hash
      (SCENARIOS_HASH[scenario] ||= []) <<  scenario_hash['scenario']['CyBOK']
    else
      # SCENARIOS_HASH[scenario]['VMs'] << scenario_hash['scenario']['system']['system_name']
    end

    if (scenario_hash['scenario']['video'].kind_of?(Array))
      scenario_hash['scenario']['video'].each {|video_entry|
        url = video_entry['url']
        (VIDEO_HASH[url] ||= []) << video_entry

      }
    elsif (scenario_hash['scenario']['video'])
      # KA_HASH[scenario] << scenario
      url = scenario_hash['scenario']['video']['url']
      (VIDEO_HASH[url] ||= []) <<  scenario_hash['scenario']['video']
    else
      # SCENARIOS_HASH[scenario]['VMs'] << scenario_hash['scenario']['system']['system_name']
    end

    # puts @ka_hash.to_s
    # puts SCENARIOS_HASH.to_s
    # SCENARIOS_HASH[scenario] = {};
    # SCENARIOS_HASH[scenario]['name'] = scenario_hash['scenario']['name']
    # SCENARIOS_HASH[scenario]['type'] = scenario_hash['scenario']['type']
    # SCENARIOS_HASH[scenario]['author'] = scenario_hash['scenario']['author']
    # SCENARIOS_HASH[scenario]['description'] = scenario_hash['scenario']['description']
    # SCENARIOS_HASH[scenario]['difficulty'] = scenario_hash['scenario']['difficulty']
    # SCENARIOS_HASH[scenario]['VMs'] = []
    # # puts '>>>>>>'
    #
    # if (scenario_hash['scenario']['system'].kind_of?(Array))
    #   scenario_hash['scenario']['system'].each {|vm|
    #     SCENARIOS_HASH[scenario]['VMs'] << vm['system_name']
    #   }
    #
    # else
    #   SCENARIOS_HASH[scenario]['VMs'] << scenario_hash['scenario']['system']['system_name']
    # end
  else
    Print.err "Error reading scenario xml: #{scenario}"
  end


}
# puts SCENARIOS_HASH.to_s

template_out = ERB.new(File.read("#{ROOT_DIR}/lib/CyBOK/template_CyBOK_scenarios.md.erb"), 0, '<>-')
begin
  File.open(scenario_index_out, 'wb+') do |file|
    file.write(template_out.result())
  end
rescue StandardError => e
  Print.err "Error writing file: #{e.message}"
  Print.err e.backtrace.inspect
end

if output_video_index
  template_out = ERB.new(File.read("#{ROOT_DIR}/lib/CyBOK/template_CyBOK_videos.md.erb"), 0, '<>-')
  begin
    File.open("#{ROOT_DIR}/README-CyBOK-Lecture-Videos.md", 'wb+') do |file|
      file.write(template_out.result())
    end
  rescue StandardError => e
    Print.err "Error writing file: #{e.message}"
    Print.err e.backtrace.inspect
  end
end

Print.std "#{SCENARIOS_HASH.length} scenarios with CyBOK metadata"
Print.std "#{VIDEO_HASH.length} videos with CyBOK metadata"
