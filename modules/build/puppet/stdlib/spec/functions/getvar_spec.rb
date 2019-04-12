require 'spec_helper'

describe 'getvar' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it { is_expected.to run.with_params('one', 'two').and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }

  it { is_expected.to run.with_params('$::foo').and_return(nil) }

  context 'given variables in namespaces' do
    let(:pre_condition) {
      <<-'ENDofPUPPETcode'
      class site::data { $foo = 'baz' }
      include site::data
      ENDofPUPPETcode
    }

    it { is_expected.to run.with_params('site::data::foo').and_return('baz') }
    it { is_expected.to run.with_params('::site::data::foo').and_return('baz') }
    it { is_expected.to run.with_params('::site::data::bar').and_return(nil) }
  end

  context 'given variables in namespaces' do
    let(:pre_condition) {
      <<-'ENDofPUPPETcode'
      class site::info { $lock = 'ŧҺîš íš ắ śţřĭŋĝ' }
      class site::new { $item = '万Ü€‰' }
      include site::info
      include site::new
      ENDofPUPPETcode
    }

    it { is_expected.to run.with_params('site::info::lock').and_return('ŧҺîš íš ắ śţřĭŋĝ') }
    it { is_expected.to run.with_params('::site::new::item').and_return('万Ü€‰') }
  end
end

