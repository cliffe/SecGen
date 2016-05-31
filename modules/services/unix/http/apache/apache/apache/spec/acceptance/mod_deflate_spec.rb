require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache::mod::deflate class' do
  context "default deflate config" do
    it 'succeeds in puppeting deflate' do
      pp= <<-EOS
        class { 'apache': }
        include apache::mod::deflate
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe service($service_name) do
      if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
        pending 'Should be enabled - Bug 760616 on Debian 8'
      else
        it { should be_enabled }
      end
      it { is_expected.to be_running }
    end

    describe file("#{$mod_dir}/deflate.conf") do
      it { is_expected.to contain "AddOutputFilterByType DEFLATE text/html text/plain text/xml" }
      it { is_expected.to contain "AddOutputFilterByType DEFLATE text/css" }
      it { is_expected.to contain "AddOutputFilterByType DEFLATE application/x-javascript application/javascript application/ecmascript" }
      it { is_expected.to contain "AddOutputFilterByType DEFLATE application/rss+xml" }
      it { is_expected.to contain "DeflateFilterNote Input instream" }
      it { is_expected.to contain "DeflateFilterNote Output outstream" }
      it { is_expected.to contain "DeflateFilterNote Ratio ratio" }
    end
  end
end
