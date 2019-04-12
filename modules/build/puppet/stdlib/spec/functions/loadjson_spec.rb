require 'spec_helper'

describe 'loadjson' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(ArgumentError, /wrong number of arguments/i) }

  describe "when calling with valid arguments" do
    before :each do
      allow(File).to receive(:read).with(/\/(stdlib|test)\/metadata.json/, {:encoding=>"utf-8"}).and_return('{"name": "puppetlabs-stdlib"}')
      allow(File).to receive(:read).with(/\/(stdlib|test)\/metadata.json/).and_return('{"name": "puppetlabs-stdlib"}')
    end

    context 'when a non-existing file is specified' do
      let(:filename) {
        if Puppet::Util::Platform.windows?
          'C:/tmp/doesnotexist'
        else
          '/tmp/doesnotexist'
        end
      }
      before {
        allow(File).to receive(:exists?).with(filename).and_return(false).once
        allow(PSON).to receive(:load).never
      }
      it { is_expected.to run.with_params(filename, {'default' => 'value'}).and_return({'default' => 'value'}) }
      it { is_expected.to run.with_params(filename, {'đẽƒằưļŧ' => '٧ẵłựέ'}).and_return({'đẽƒằưļŧ' => '٧ẵłựέ'}) }
      it { is_expected.to run.with_params(filename, {'デフォルト' => '値'}).and_return({'デフォルト' => '値'}) }
    end

    context 'when an existing file is specified' do
      let(:filename) {
        if Puppet::Util::Platform.windows?
          'C:/tmp/doesexist'
        else
          '/tmp/doesexist'
        end
      }
      let(:data) { { 'key' => 'value', 'ķęŷ' => 'νậŀųề', 'キー' => '値'} }
      let(:json) { '{"key":"value", {"ķęŷ":"νậŀųề" }, {"キー":"値" }' }
      before {
        allow(File).to receive(:exists?).with(filename).and_return(true).once
        allow(File).to receive(:read).with(filename).and_return(json).once
        allow(File).to receive(:read).with(filename).and_return(json).once
        allow(PSON).to receive(:load).with(json).and_return(data).once
      }
      it { is_expected.to run.with_params(filename).and_return(data) }
    end

    context 'when the file could not be parsed' do
      let(:filename) {
        if Puppet::Util::Platform.windows?
          'C:/tmp/doesexist'
        else
          '/tmp/doesexist'
        end
      }
      let(:json) { '{"key":"value"}' }
      before {
        allow(File).to receive(:exists?).with(filename).and_return(true).once
        allow(File).to receive(:read).with(filename).and_return(json).once
        allow(PSON).to receive(:load).with(json).once.and_raise StandardError, 'Something terrible have happened!'
      }
      it { is_expected.to run.with_params(filename, {'default' => 'value'}).and_return({'default' => 'value'}) }
    end
  end
end
