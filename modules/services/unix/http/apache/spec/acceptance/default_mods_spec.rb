require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache::default_mods class' do
  describe 'no default mods' do
    # Using puppet_apply as a helper
    let(:pp) do
      <<-EOS
        class { 'apache':
          default_mods => false,
        }
      EOS
    end

    # Run it twice and test for idempotency
    it_behaves_like "a idempotent resource"
    describe service($service_name) do
      it { is_expected.to be_running }
    end
  end

  unless (fact('operatingsystem') == 'SLES' && fact('operatingsystemmajrelease') == '12')
    describe 'no default mods and failing' do
      before :all do
        pp = <<-PP
        include apache::params
        class { 'apache': default_mods => false, service_ensure => stopped, }
        PP
        apply_manifest(pp)
      end
      # Using puppet_apply as a helper
      it 'should apply with errors' do
        pp = <<-EOS
          class { 'apache':
            default_mods => false,
          }
          apache::vhost { 'defaults.example.com':
            docroot     => '#{$doc_root}/defaults',
            aliases     => {
              alias => '/css',
              path  => '#{$doc_root}/css',
            },
            directories => [
            {
                'path'            => "#{$doc_root}/admin",
                'auth_basic_fake' => 'demo demopass',
              }
            ],
            setenv      => 'TEST1 one',
          }
        EOS

        apply_manifest(pp, { :expect_failures => true })
      end
  end

    describe service($service_name) do
      it { is_expected.not_to be_running }
    end
  end

  describe 'alternative default mods' do
    # Using puppet_apply as a helper
    let(:pp) do
      <<-EOS
        class { 'apache':
          default_mods => [
            'info',
            'alias',
            'mime',
            'env',
            'expires',
          ],
        }
        apache::vhost { 'defaults.example.com':
          docroot => '#{$doc_root}/defaults',
          aliases => {
            alias => '/css',
            path  => '#{$doc_root}/css',
          },
          setenv  => 'TEST1 one',
        }
      EOS
    end
    it_behaves_like "a idempotent resource"

    describe service($service_name) do
      it { is_expected.to be_running }
    end
  end

  describe 'change loadfile name' do
    let(:pp) do
      <<-EOS
        class { 'apache': default_mods => false }
        ::apache::mod { 'auth_basic':
          loadfile_name => 'zz_auth_basic.load',
        }
      EOS
    end
    # Run it twice and test for idempotency
    it_behaves_like "a idempotent resource"
    describe service($service_name) do
      it { is_expected.to be_running }
    end

    describe file("#{$mod_dir}/zz_auth_basic.load") do
      it { is_expected.to be_file }
    end
  end
end
