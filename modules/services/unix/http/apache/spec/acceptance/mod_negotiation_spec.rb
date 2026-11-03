require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache::mod::negotiation class' do
  context "default negotiation config" do
    it 'succeeds in puppeting negotiation' do
      pp= <<-EOS
        class { '::apache': default_mods => false }
        class { '::apache::mod::negotiation': }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$mod_dir}/negotiation.conf") do
      it { should contain "LanguagePriority en ca cs da de el eo es et fr he hr it ja ko ltz nl nn no pl pt pt-BR ru sv zh-CN zh-TW
ForceLanguagePriority Prefer Fallback" }
    end

    describe service($service_name) do
      if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
        pending 'Should be enabled - Bug 760616 on Debian 8'
      else
        it { should be_enabled }
      end
      it { should be_running }
    end
  end

  context "with alternative force_language_priority" do
    it 'succeeds in puppeting negotiation' do
      pp= <<-EOS
        class { '::apache': default_mods => false }
        class { '::apache::mod::negotiation':
          force_language_priority => 'Prefer',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$mod_dir}/negotiation.conf") do
      it { should contain "ForceLanguagePriority Prefer" }
    end

    describe service($service_name) do
      if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
        pending 'Should be enabled - Bug 760616 on Debian 8'
      else
        it { should be_enabled }
      end
      it { should be_running }
    end
  end

  context "with alternative language_priority" do
    it 'succeeds in puppeting negotiation' do
      pp= <<-EOS
        class { '::apache': default_mods => false }
        class { '::apache::mod::negotiation':
          language_priority => [ 'en', 'es' ],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$mod_dir}/negotiation.conf") do
      it { should contain "LanguagePriority en es" }
    end

    describe service($service_name) do
      if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
        pending 'Should be enabled - Bug 760616 on Debian 8'
      else
        it { should be_enabled }
      end
      it { should be_running }
    end
  end
end
