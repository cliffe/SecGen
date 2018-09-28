require 'master_manipulator'
require 'chocolatey_helper'
test_name 'MODULES-3043 - C97739 - Install Client on Virgin System'

chocolatey_pp = <<MANIFEST
  class {'chocolatey':
    chocolatey_download_url => 'file:///C:/chocolatey.nupkg',
    use_7zip                => false,
  }
MANIFEST

chocoVersion = /[0-9]+[\d'.']*/

# Setup
step 'Inject "site.pp" on Master'
site_pp = create_site_pp(master, :manifest => chocolatey_pp)
inject_site_pp(master, get_site_pp_path(master), site_pp)

#Test
confine_block(:to, :platform => 'windows') do

  agents.each do |agent|
    opts = {
        :acceptable_exit_codes => [0, 2]
    }

    url = get_latest_chocholatey_download_url

    step 'Download chocolatey nuget package' do
      curl_on(agent, "#{url} > C:/chocolatey.nupkg")
    end

    step 'should apply chocolatey manifest and install choco.exe' do
      on(agent, puppet('agent -t --environment production'), opts) do |result|
        assert_no_match(/Error:/, result.stderr, 'Unexpected error was detected!')
      end
    end

    step 'should have valid version of Chocolatey' do
      on(agent, 'C:/ProgramData/chocolatey/bin/choco.exe -v', :acceptable_exit_codes => 0) do |result|
        assert_match(chocoVersion, result.stdout, 'Expected: ' + chocoVersion.to_s + ' but got ' + result.stdout)
      end
    end

  end

end
