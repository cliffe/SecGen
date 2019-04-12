require 'spec_helper'
describe 'sqlmap' do

  context 'with defaults for all parameters' do
    it { should contain_class('sqlmap') }
  end
end
