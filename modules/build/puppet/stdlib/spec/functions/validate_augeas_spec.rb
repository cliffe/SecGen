require 'spec_helper'

describe 'validate_augeas' do
  if Puppet.features.augeas?
    describe 'signature validation' do
      it { is_expected.not_to eq(nil) }
      it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
      it { is_expected.to run.with_params('').and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
      it { is_expected.to run.with_params('', '', [], '', 'extra').and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
      it { is_expected.to run.with_params('one', 'one', 'MSG to User', '4th arg').and_raise_error(NoMethodError) }
    end

    describe 'valid inputs' do
      inputs = [
        ["root:x:0:0:root:/root:/bin/bash\n", 'Passwd.lns'],
        ["proc /proc   proc    nodev,noexec,nosuid     0       0\n", 'Fstab.lns'],
      ]

      inputs.each do |input|
        it { is_expected.to run.with_params(*input) }
      end
    end

    describe 'valid inputs which fail augeas validation' do
      # The intent here is to make sure valid inputs raise exceptions when they
      # don't specify an error message to display.  This is the behvior in
      # 2.2.x and prior.
      inputs = [
        ["root:x:0:0:root\n", 'Passwd.lns'],
        ["127.0.1.1\n", 'Hosts.lns'],
      ]

      inputs.each do |input|
        it { is_expected.to run.with_params(*input).and_raise_error(Puppet::ParseError, %r{validate_augeas.*?matched less than it should}) }
      end
    end

    describe 'when specifying nice error messages' do
      # The intent here is to make sure the function returns the 4th argument
      # in the exception thrown
      inputs = [
        ["root:x:0:0:root\n", 'Passwd.lns', [], 'Failed to validate passwd content'],
        ["127.0.1.1\n", 'Hosts.lns', [], 'Wrong hosts content'],
      ]

      inputs.each do |input|
        it { is_expected.to run.with_params(*input).and_raise_error(Puppet::ParseError, %r{#{input[3]}}) }
      end
    end

    describe 'matching additional tests' do
      inputs = [
        ["root:x:0:0:root:/root:/bin/bash\n", 'Passwd.lns', ['$file/foobar']],
        ["root:x:0:0:root:/root:/bin/bash\n", 'Passwd.lns', ['$file/root/shell[.="/bin/sh"]', 'foobar']],
      ]

      inputs.each do |input|
        it { is_expected.to run.with_params(*input) }
      end
    end

    describe 'failing additional tests' do
      inputs = [
        ["foobar:x:0:0:root:/root:/bin/bash\n", 'Passwd.lns', ['$file/foobar']],
        ["root:x:0:0:root:/root:/bin/sh\n", 'Passwd.lns', ['$file/root/shell[.="/bin/sh"]', 'foobar']],
      ]

      inputs.each do |input|
        it { is_expected.to run.with_params(*input).and_raise_error(Puppet::ParseError, %r{testing path}) }
      end
    end
  else
    skip 'ruby-augeas not installed'
  end
end
