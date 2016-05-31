require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache::custom_config define' do
  context 'invalid config' do
    it 'should not add the config' do
      pp = <<-EOS
        class { 'apache': }
        apache::custom_config { 'acceptance_test':
          content => 'INVALID',
        }
      EOS

      apply_manifest(pp, :expect_failures => true)
    end

    describe file("#{$confd_dir}/25-acceptance_test.conf") do
      it { is_expected.not_to be_file }
    end
  end

  context 'valid config' do
    it 'should add the config' do
      pp = <<-EOS
        class { 'apache': }
        apache::custom_config { 'acceptance_test':
          content => '# just a comment',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$confd_dir}/25-acceptance_test.conf") do
      it { is_expected.to contain '# just a comment' }
    end
  end

  context 'with a custom filename' do
    it 'should store content in the described file' do
      pp = <<-EOS
        class { 'apache': }
        apache::custom_config { 'filename_test':
          filename => 'custom_filename',
          content  => '# just another comment',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$confd_dir}/custom_filename") do
      it { is_expected.to contain '# just another comment' }
    end
  end

  describe 'custom_config without priority prefix' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        apache::custom_config { 'prefix_test':
          priority => false,
          content => '# just a comment',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$confd_dir}/prefix_test.conf") do
      it { is_expected.to be_file }
    end
  end

  describe 'custom_config only applied after configs are written' do
    it 'applies in the right order' do
      pp = <<-EOS
        class { 'apache': }

        apache::custom_config { 'ordering_test':
          content => '# just a comment',
        }

        # Try to wedge the apache::custom_config call between when httpd.conf is written and
        # ports.conf is written. This should trigger a dependency cycle
        File["#{$conf_file}"] -> Apache::Custom_config['ordering_test'] -> Concat["#{$ports_file}"]
      EOS
      expect(apply_manifest(pp, :expect_failures => true).stderr).to match(/Found 1 dependency cycle/i)
    end

    describe file("#{$confd_dir}/25-ordering_test.conf") do
      it { is_expected.not_to be_file }
    end
  end
end
