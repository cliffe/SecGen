require 'spec_helper'

describe 'test::ensure_resources', type: :class do
  let(:params) {{ resource_type: 'user', title_hash: title_param, attributes_hash: {'ensure' => 'present'} }}

  describe 'given a title hash of multiple resources' do

    let(:title_param) { {'dan' => { 'gid' => 'mygroup', 'uid' => '600' }, 'alex' => { 'gid' => 'mygroup', 'uid' => '700'}} }

    it { is_expected.to compile }
    it { is_expected.to contain_user('dan').with({ 'gid' => 'mygroup', 'uid' => '600', 'ensure' => 'present'}) }
    it { is_expected.to contain_user('alex').with({ 'gid' => 'mygroup', 'uid' => '700', 'ensure' => 'present'}) }
  end

  describe 'given a title hash of a single resource' do

    let(:title_param) { {'dan' => { 'gid' => 'mygroup', 'uid' => '600' }} }

    it { is_expected.to compile }
    it { is_expected.to contain_user('dan').with({ 'gid' => 'mygroup', 'uid' => '600', 'ensure' => 'present'}) }
  end
end
