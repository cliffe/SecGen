require_relative '../../../../../lib/post_provision_test'
require 'json'

class PcapFileTest < PostProvisionTest
  def initialize
    self.module_name = 'pcap_file'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Where init.pp leaks the file: /home/<user>/<name> when an account is given,
  # otherwise <storage_directory>/<name> (defaults: /var/log, capture.pcap).
  def leaked_path
    name = self.json_inputs['leaked_filename']&.first || 'capture.pcap'
    acct = self.json_inputs['account']&.first
    if acct && acct != ''
      user = (JSON.parse(acct)['username'] rescue nil)
      return "/home/#{user}/#{name}" if user
    end
    dir = self.json_inputs['storage_directory']&.first || '/var/log'
    "#{dir.chomp('/')}/#{name}"
  end

  def test_module
    super
    path = Shellwords.escape(leaked_path)
    tier(1) do
      test_command_succeeds("leaked file #{leaked_path} exists", "test -f #{path}")
    end
    tier(2) do
      # libpcap begins d4c3b2a1 (LE, what the pcap_generator/PacketFu writes) or
      # a1b2c3d4 (BE); pcapng begins 0a0d0d0a. Emit a fixed marker on any match so
      # the substring check is signature-agnostic.
      test_local_command('pcap magic bytes present',
                         "xxd -p -l4 #{path} | grep -qiE '^(d4c3b2a1|a1b2c3d4|0a0d0d0a)' && echo PCAP_MAGIC_OK",
                         'PCAP_MAGIC_OK')
    end
    # TODO tier 3 (exploit): deferred — challenge is a CTF analysis task, no remote exploit
  end
end

PcapFileTest.new.run
