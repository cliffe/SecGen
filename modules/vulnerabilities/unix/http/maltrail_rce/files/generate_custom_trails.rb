#!/usr/bin/env ruby
# Script to generate MalTrail custom trails file from JSON data
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
  
  # Generate custom trails content
  trails = []
  
  # Add header comment
  trails << "# Custom trails for SecGen training scenario"
  trails << "# Generated automatically by Puppet provisioning"
  trails << "#"
  trails << "# Malicious IPs"
  
  # Add IP-based trails
  data['custom_trails'].each do |trail_entry|
    # Check if it's an IP (starts with a number)
    if trail_entry =~ /^\d/
      trails << trail_entry
    end
  end
  
  trails << "#"
  trails << "# Malicious domains"
  
  # Add domain-based trails
  data['custom_trails'].each do |trail_entry|
    # Check if it's a domain (starts with a letter)
    if trail_entry =~ /^[a-z]/i
      trails << trail_entry
    end
  end
  
  # Output the trails content
  puts trails.join("\n")
  
rescue JSON::ParserError => e
  STDERR.puts "Error parsing JSON: #{e.message}"
  exit 1
rescue => e
  STDERR.puts "Error: #{e.message}"
  exit 1
end