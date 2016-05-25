require 'spec_helper'

describe 'mysql::server' do
  context "on an unsupported OS" do
    # fetch any sets of facts to modify them
    os, facts = on_supported_os.first

    let(:facts) {
      facts.merge({
        :osfamily => 'UNSUPPORTED',
        :operatingsystem => 'UNSUPPORTED',
      })
    }

    it 'should gracefully fail' do
      is_expected.to compile.and_raise_error(/Unsupported platform:/)
    end
  end
end
