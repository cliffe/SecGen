require 'spec_helper'

describe 'load_module_metadata' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it { is_expected.to run.with_params("one", "two", "three").and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }

  describe "when calling with valid arguments" do
    before :each do
      allow(File).to receive(:read).with(/\/(stdlib|test)\/metadata.json/, {:encoding=>"utf-8"}).and_return('{"name": "puppetlabs-stdlib"}')
      allow(File).to receive(:read).with(/\/(stdlib|test)\/metadata.json/).and_return('{"name": "puppetlabs-stdlib"}')
    end

    context "when calling with valid utf8 and double byte character arguments" do
      before :each do
        allow(File).to receive(:read).with(/\/(stdlib|test)\/metadata.json/, {:encoding=>"utf-8"}).and_return('{"ĭďèŉţĩƒіểя": "ċơņťęאּť ỡƒ ţħíš -
この文字"}')
        allow(File).to receive(:read).with(/\/(stdlib|test)\/metadata.json/).and_return('{"ĭďèŉţĩƒіểя": "ċơņťęאּť ỡƒ ţħíš -
この文字"}')
      end

    it "should json parse the file" do
      if Puppet::Util::Platform.windows?
        allow(scope).to receive(:function_get_module_path).with(['science']).and_return('C:/path/to/module/')
        allow(File).to receive(:exists?).with('C:/path/to/module/metadata.json').and_return(true)
        allow(File).to receive(:read).with('C:/path/to/module/metadata.json').and_return('{"name": "spencer-science"}')
      else
        allow(scope).to receive(:function_get_module_path).with(['science']).and_return('/path/to/module/')
        allow(File).to receive(:exists?).with('/path/to/module/metadata.json').and_return(true)
        allow(File).to receive(:read).with('/path/to/module/metadata.json').and_return('{"name": "spencer-science"}')
      end

      result = subject.call(['science'])
      expect(result['name']).to eq('spencer-science')
    end

    it "should fail by default if there is no metadata.json" do
      if Puppet::Util::Platform.windows?
        allow(scope).to receive(:function_get_module_path).with(['science']).and_return('C:/path/to/module/')
        allow(File).to receive(:exists?).with('C:/path/to/module/metadata.json').and_return(false)
      else
        allow(scope).to receive(:function_get_module_path).with(['science']).and_return('/path/to/module/')
        allow(File).to receive(:exists?).with('/path/to/module/metadata.json').and_return(false)
      end
      expect {subject.call(['science'])}.to raise_error(Puppet::ParseError)
    end

    it "should return nil if user allows empty metadata.json" do
      if Puppet::Util::Platform.windows?
        allow(scope).to receive(:function_get_module_path).with(['science']).and_return('C:/path/to/module/')
        allow(File).to receive(:exists?).with('C:/path/to/module/metadata.json').and_return(false)
      else
        allow(scope).to receive(:function_get_module_path).with(['science']).and_return('/path/to/module/')
        allow(File).to receive(:exists?).with('/path/to/module/metadata.json').and_return(false)
      end
      result = subject.call(['science', true])
      expect(result).to eq({})
    end
    end
  end
end
