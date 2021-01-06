require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'deprecation' do
    before(:each) do
      # this is to reset the strict variable to default
      Puppet.settings[:strict] = :warning
    end

    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params.and_raise_error(ArgumentError) }

    it 'displays a single warning' do
      Puppet.expects(:warning).with(includes('heelo'))
      is_expected.to run.with_params('key', 'heelo')
    end

    it 'displays a single warning, despite multiple calls' do
      Puppet.expects(:warning).with(includes('heelo')).once
      (0..1).each do |_i|
        is_expected.to run.with_params('key', 'heelo')
      end
    end

    it 'fails twice with message, with multiple calls. when strict= :error' do
      Puppet.settings[:strict] = :error
      Puppet.expects(:warning).with(includes('heelo')).never
      (0..1).each do |_i|
        is_expected.to run.with_params('key', 'heelo').and_raise_error(RuntimeError, %r{deprecation. key. heelo})
      end
    end

    it 'displays nothing, despite multiple calls. strict= :off' do
      Puppet.settings[:strict] = :off
      Puppet.expects(:warning).with(includes('heelo')).never
      (0..1).each do |_i|
        is_expected.to run.with_params('key', 'heelo')
      end
    end

    after(:each) do
      # this is to reset the strict variable to default
      Puppet.settings[:strict] = :warning
    end
  end
elsif Puppet.version.to_f < 4.0
  # Puppet version < 4 will use these tests.
  describe 'deprecation' do
    after(:each) do
      ENV.delete('STDLIB_LOG_DEPRECATIONS')
    end
    before(:each) do
      ENV['STDLIB_LOG_DEPRECATIONS'] = 'true'
    end
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }

    it 'displays a single warning' do
      scope.expects(:warning).with(includes('heelo'))
      is_expected.to run.with_params('key', 'heelo')
    end
  end
end
