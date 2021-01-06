require 'spec_helper'

describe 'ensure_resources' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(ArgumentError, %r{Must specify a type}) }
  it { is_expected.to run.with_params('type').and_raise_error(ArgumentError, %r{Must specify a title}) }

  describe 'given a title hash of multiple resources' do
    before(:each) { subject.call(['user', { 'dan' => { 'gid' => 'mygroup', 'uid' => '600' }, 'alex' => { 'gid' => 'mygroup', 'uid' => '700' } }, { 'ensure' => 'present' }]) }

    # this lambda is required due to strangeness within rspec-puppet's expectation handling
    it { expect(-> { catalogue }).to contain_user('dan').with_ensure('present') }
    it { expect(-> { catalogue }).to contain_user('alex').with_ensure('present') }
    it { expect(-> { catalogue }).to contain_user('dan').with('gid' => 'mygroup', 'uid' => '600') }
    it { expect(-> { catalogue }).to contain_user('alex').with('gid' => 'mygroup', 'uid' => '700') }
  end

  describe 'given a title hash of a single resource' do
    before(:each) { subject.call(['user', { 'dan' => { 'gid' => 'mygroup', 'uid' => '600' } }, { 'ensure' => 'present' }]) }

    # this lambda is required due to strangeness within rspec-puppet's expectation handling
    it { expect(-> { catalogue }).to contain_user('dan').with_ensure('present') }
    it { expect(-> { catalogue }).to contain_user('dan').with('gid' => 'mygroup', 'uid' => '600') }
  end
end
