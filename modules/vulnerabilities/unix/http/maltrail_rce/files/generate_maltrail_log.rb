#!/usr/bin/env ruby
# Script to generate MalTrail log entries from JSON data
# Called by Puppet during provisioning
require 'json'

# Read JSON input from command line argument
if ARGV.empty?
  puts "Usage: #{$0} '<json_data>'"
  exit 1
end

begin
  # Parse the JSON data
  data = JSON.parse(ARGV[0])
  
  # Generate log entries
  log_lines = []
  
  data['events'].each do |event|
    # Format: "timestamp" sensor src_ip src_port dst_ip dst_port proto trail_type trail trail_info reference
    log_line = "\"#{event['timestamp']}\" #{event['sensor']} #{event['src_ip']} #{event['src_port']} #{event['dst_ip']} #{event['dst_port']} #{event['proto']} #{event['trail_type']} #{event['trail']} #{event['trail_info']} #{event['reference']}"
    log_lines << log_line
  end
  
  # Output the log content
  puts log_lines.join("\n")
  
rescue JSON::ParserError => e
  STDERR.puts "Error parsing JSON: #{e.message}"
  exit 1
rescue => e
  STDERR.puts "Error: #{e.message}"
  exit 1
end