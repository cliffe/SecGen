require 'spec_helper'

describe 'validate_cmd', :unless => Puppet::Util::Platform.windows? do
  let(:touch) { File.exist?('/usr/bin/touch') ? '/usr/bin/touch' : '/bin/touch' }

  describe 'signature validation' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
    it { is_expected.to run.with_params('').and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
    it { is_expected.to run.with_params('', '', '', 'extra').and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
    it {
      pending('should implement stricter type checking')
      is_expected.to run.with_params([], '', '').and_raise_error(Puppet::ParseError, %r{content must be a string})
    }
    it {
      pending('should implement stricter type checking')
      is_expected.to run.with_params('', [], '').and_raise_error(Puppet::ParseError, %r{checkscript must be a string})
    }
    it {
      pending('should implement stricter type checking')
      is_expected.to run.with_params('', '', []).and_raise_error(Puppet::ParseError, %r{custom error message must be a string})
    }
  end

  context 'when validation fails' do
    context 'with % placeholder' do
      it {
        is_expected.to run
          .with_params('', "#{touch} % /no/such/file").and_raise_error(Puppet::ParseError, %r{Execution of '#{touch} \S+ \/no\/such\/file' returned 1:.*(cannot touch|o such file or)})
      }
      it { is_expected.to run.with_params('', "#{touch} % /no/such/file", 'custom error').and_raise_error(Puppet::ParseError, %r{custom error}) }
    end
    context 'without % placeholder' do
      it {
        is_expected.to run
          .with_params('', "#{touch} /no/such/file").and_raise_error(Puppet::ParseError, %r{Execution of '#{touch} \/no\/such\/file \S+' returned 1:.*(cannot touch|o such file or)})
      }
      it { is_expected.to run.with_params('', "#{touch} /no/such/file", 'custom error').and_raise_error(Puppet::ParseError, %r{custom error}) }
    end
  end
end
