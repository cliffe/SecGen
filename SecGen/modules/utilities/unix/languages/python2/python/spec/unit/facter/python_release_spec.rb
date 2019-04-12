require "spec_helper"

describe Facter::Util::Fact do
  before {
    Facter.clear
  }

  let(:python2_version_output) { <<-EOS
Python 2.7.9
EOS
  }
  let(:python3_version_output) { <<-EOS
Python 3.3.0
EOS
  }

  describe "python_release" do
    context 'returns Python release when `python` present' do
      it do
        Facter::Util::Resolution.stubs(:exec)
        Facter::Util::Resolution.expects(:which).with("python").returns(true)
        Facter::Util::Resolution.expects(:exec).with("python -V 2>&1").returns(python2_version_output)
        expect(Facter.value(:python_release)).to eq("2.7")
      end
    end

    context 'returns nil when `python` not present' do
      it do
        Facter::Util::Resolution.stubs(:exec)
        Facter::Util::Resolution.expects(:which).with("python").returns(false)
        expect(Facter.value(:python_release)).to eq(nil)
      end
    end

  end

  describe "python2_release" do
    context 'returns Python 2 release when `python` is present and Python 2' do
      it do
        Facter::Util::Resolution.stubs(:exec)
        Facter::Util::Resolution.expects(:which).with("python").returns(true)
        Facter::Util::Resolution.expects(:exec).with("python -V 2>&1").returns(python2_version_output)
        expect(Facter.value(:python2_release)).to eq('2.7')
      end
    end

    context 'returns Python 2 release when `python` is Python 3 and `python2` is present' do
      it do
        Facter::Util::Resolution.stubs(:exec)
        Facter::Util::Resolution.expects(:which).with("python").returns(true)
        Facter::Util::Resolution.expects(:exec).with("python -V 2>&1").returns(python3_version_output)
        Facter::Util::Resolution.expects(:which).with("python2").returns(true)
        Facter::Util::Resolution.expects(:exec).with("python2 -V 2>&1").returns(python2_version_output)
        expect(Facter.value(:python2_release)).to eq('2.7')
      end
    end

    context 'returns nil when `python` is Python 3 and `python2` is absent' do
      it do
        Facter::Util::Resolution.stubs(:exec)
        Facter::Util::Resolution.expects(:which).with("python").returns(true)
        Facter::Util::Resolution.expects(:exec).with("python -V 2>&1").returns(python3_version_output)
        Facter::Util::Resolution.expects(:which).with("python2").returns(false)
        expect(Facter.value(:python2_release)).to eq(nil)
      end
    end

    context 'returns nil when `python2` and `python` are absent' do
      it do
        Facter::Util::Resolution.stubs(:exec)
        Facter::Util::Resolution.expects(:which).with("python").returns(false)
        Facter::Util::Resolution.expects(:which).with("python2").returns(false)
        expect(Facter.value(:python2_release)).to eq(nil)
      end
    end

  end

  describe "python3_release" do
    context 'returns Python 3 release when `python3` present' do
      it do
        Facter::Util::Resolution.stubs(:exec)
        Facter::Util::Resolution.expects(:which).with("python3").returns(true)
        Facter::Util::Resolution.expects(:exec).with("python3 -V 2>&1").returns(python3_version_output)
        expect(Facter.value(:python3_release)).to eq("3.3")
      end
    end

    context 'returns nil when `python3` not present' do
      it do
        Facter::Util::Resolution.stubs(:exec)
        Facter::Util::Resolution.expects(:which).with("python3").returns(false)
        expect(Facter.value(:python3_release)).to eq(nil)
      end
    end

  end
end
