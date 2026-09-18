#!/usr/bin/ruby
# Render a hackerbot_config generator's lab sheet as MARKDOWN (pre-HTML),
# using placeholder account data so every substituted value is recognisable.
#
# Usage: render_labsheet.rb <generator_module_dir> [--real]
#
#   default : accounts are obviously-fake sentinels (MAINUSER/SECONDUSER/...)
#             so you can grep the output for what was parameterised.
#   --real  : plausible values, to read the sheet as a student would.
#
# Writes markdown to stdout; diagnostics to stderr.

require 'json'

secgen_root = ARGV[0] && File.expand_path(ARGV[0])
abort "usage: render_labsheet.rb <generator_module_dir> [--real]" unless secgen_root && File.directory?(secgen_root)
real = ARGV.include?('--real')

# Walk up to the SecGen root to find lib/
root = secgen_root
root = File.dirname(root) until File.directory?(File.join(root, 'lib', 'objects')) || root == '/'
abort "could not locate SecGen lib/objects above #{secgen_root}" if root == '/'
require File.join(root, 'lib', 'objects', 'local_hackerbot_config_generator.rb')

files = %w[trade_secrets/code.pl trade_secrets/credit_card personal_secrets/credit_card logs/log1 personal_secrets/address_book]

main   = real ? 'griffin' : 'MAINUSER'
second = real ? 'chimera' : 'SECONDUSER'

accounts = [
  { 'username' => main,   'password' => 'tiaspbiqe2r', 'super_user' => 'true',
    'leaked_filenames' => files, 'strings_to_leak' => files.map { 'LEAKED CONTENT' } },
  { 'username' => second, 'password' => 'test', 'super_user' => 'false',
    'leaked_filenames' => [], 'strings_to_leak' => [] },
]

g = HackerbotConfigGenerator.new
g.local_dir            = secgen_root
g.templates_path       = "#{secgen_root}/templates/"
g.config_template_path = "#{secgen_root}/templates/#{Dir.children("#{secgen_root}/templates").grep(/\.xml\.erb\z/).first}"
g.accounts             = accounts.map(&:to_json)
g.flags                = (1..8).map { |i| real ? "flag{#{'%032x' % rand(2**128)}}" : "FLAG#{i}" }
g.root_password        = 'ROOTPASSWORD'

xml = ERB.new(File.read(g.config_template_path), 0, '<>-').result(g.get_binding)
warn "rendered config: #{g.config_template_path}"
puts g.generate_lab_sheet(xml)
