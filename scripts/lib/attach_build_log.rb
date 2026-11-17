# Copies a secgen-dev-run build log into test_results/<project-id>/build.log with the
# Proxmox password and LLM API key masked (read from SECGEN_PROXMOX_PASS /
# SECGEN_LLM_API_KEY, never command-line arguments), and records it in that
# run's summary.json.
#
# Usage: SECGEN_PROXMOX_PASS=... ruby attach_build_log.rb <output dir> <log file> <project id>
# (<output dir> holds test_results/: SECGEN_OUTPUT_DIR, or the SecGen checkout)
require 'json'
require 'fileutils'

output_dir, log, project_id = ARGV
abort 'Usage: attach_build_log.rb <output dir> <log file> <project id>' unless project_id && File.file?(log.to_s)
out = File.join(output_dir, 'test_results', project_id)
summary_path = File.join(out, 'summary.json')
exit 0 unless File.exist?(summary_path) # not a test run

data = File.binread(log)
count = 0
%w[SECGEN_PROXMOX_PASS SECGEN_LLM_API_KEY].each do |var|
  secret = ENV[var].to_s.b
  next if secret.empty?
  found = data.scan(secret).size
  data = data.gsub(secret, '********') if found > 0
  count += found
end
File.binwrite(File.join(out, 'build.log'), data)

summary = JSON.parse(File.read(summary_path))
summary['build'] ||= {}
summary['build']['log'] = 'build.log'
summary['masked_secrets'] = summary['masked_secrets'].to_i + count
File.write(summary_path, JSON.pretty_generate(summary) + "\n")
warn "Masked #{count} occurrence(s) of the Proxmox password / LLM API key in build.log" if count > 0
puts "Build log: #{File.join('test_results', project_id, 'build.log')}"
