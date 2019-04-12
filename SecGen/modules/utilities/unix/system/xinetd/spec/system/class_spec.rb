require 'spec_helper_system'

describe 'xinetd class' do
  describe puppet_apply(<<-EOS
        class { 'xinetd': }
      EOS
  ) do

    its(:exit_code) { should_not eq(1) }
    its(:refresh) { should be_nil }
    its(:exit_code) { should be_zero }
  end

  describe service('xinetd') do
    it { should be_running }
    it { should be_enabled }
  end
end
