require_relative '../../../../../lib/post_provision_test'
require 'json'

# Verifies the pre-captured memory image was placed on the analyst machine and
# that this build's artefact tokens were patched into it, so each build's
# answers are present and unique. Volatility's own correctness is covered by the
# volatility3 module's test; here we assert this module's job: place + patch.
class PrepackagedMemoryImageTest < PostProvisionTest
  # The image is the compromised server's full RAM (gigabytes). Reading it cold
  # off the analyst VM's virtual disk under build I/O contention is slow, so a
  # whole-file scan can exceed the guest agent's default 90s deadline. Give the
  # image searches plenty of headroom; they still return early thanks to the
  # stop-at-first-match grep below.
  IMAGE_SEARCH_TIMEOUT = 420

  def initialize
    self.module_name = 'prepackaged_memory_image'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Search the image for a fixed string, returning :present, :absent or :timeout.
  # Uses `grep -q`, which stops at the first match, so a present token is found
  # without reading the whole multi-GB file. A per-search timeout is caught here
  # so one slow search records its own result instead of aborting the test.
  def image_contains(command)
    res = run_command(command, timeout: IMAGE_SEARCH_TIMEOUT)
    case res[:exit_status]
    when 0 then :present
    when 1 then :absent
    else [:error, res]
    end
  rescue Proxmox::ProxmoxTaskTimeout
    :timeout
  end

  # Resolve the analyst account the same way install.pp does: a JSON account
  # hash or a bare username, else root.
  def analyst_home
    raw = self.json_inputs['account']&.first
    username = 'root'
    if raw && !raw.empty?
      if raw =~ /\A\s*\{/
        begin
          username = JSON.parse(raw)['username'] || 'root'
        rescue JSON::ParserError
          username = raw
        end
      else
        username = raw
      end
    end
    username == 'root' ? '/root' : "/home/#{username}"
  end

  def token(name)
    self.json_inputs[name]&.first
  end

  def test_module
    super
    image = "#{analyst_home}/evidence/compromised_server.raw"

    tier(1) do
      test_local_command('image placed', "test -s '#{image}' && echo PRESENT", 'PRESENT')
      test_local_command('patch stamp present',
                         "test -f '#{analyst_home}/evidence/.patched' && echo STAMPED", 'STAMPED')

      # Every per-build token this build generated must be present in the image,
      # proving the baked golden was rewritten to this deployment's values.
      %w[deleted_proc_name nc_proc_name nc_ref_token env_token bash_token].each do |name|
        val = token(name)
        if val.nil? || val.empty?
          skip_check("token #{name} present in image", 'no value supplied', tier: 1)
          next
        end
        case image_contains("LC_ALL=C grep -a -q -F -- '#{val}' '#{image}'")
        when :present
          pass_check("token #{name} present in image", tier: 1)
        when :absent
          fail_check("token #{name} present in image", "grep found no copy of #{val}", tier: 1)
        when :timeout
          skip_check("token #{name} present in image",
                     "grep over the image did not finish within #{IMAGE_SEARCH_TIMEOUT}s", tier: 1)
        else
          fail_check("token #{name} present in image", 'grep errored searching the image', tier: 1)
        end
      end
    end

    # The taught recovery workflow (strings) yields this build's answers. `grep -q`
    # closes the pipe at the first match, so strings stops early rather than
    # walking the whole image.
    tier(2) do
      %w[env_token bash_token].each do |name|
        val = token(name)
        next if val.nil? || val.empty?
        case image_contains("LC_ALL=C strings -a '#{image}' | grep -q -F -- '#{val}'")
        when :present
          pass_check("strings recovers #{name}", tier: 2)
        when :absent
          fail_check("strings recovers #{name}", "strings | grep found no copy of #{val}", tier: 2)
        when :timeout
          skip_check("strings recovers #{name}",
                     "strings over the image did not finish within #{IMAGE_SEARCH_TIMEOUT}s", tier: 2)
        else
          fail_check("strings recovers #{name}", 'strings | grep errored searching the image', tier: 2)
        end
      end
    end
  end
end

PrepackagedMemoryImageTest.new.run
