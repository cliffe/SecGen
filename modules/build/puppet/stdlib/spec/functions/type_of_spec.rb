require 'spec_helper'

if ENV["FUTURE_PARSER"] == 'yes'
  describe 'type_of' do
    pending 'teach rspec-puppet to load future-only functions under 3.7.5' do
      it { is_expected.not_to eq(nil) }
    end
  end
end

if Puppet.version.to_f >= 4.0
  describe 'type_of' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params().and_raise_error(ArgumentError) }
    it { is_expected.to run.with_params('', '').and_raise_error(ArgumentError) }

    it 'gives the type of a string' do
      expect(subject.call({}, 'hello world')).to be_kind_of(Puppet::Pops::Types::PStringType)
    end

    it 'gives the type of an integer' do
      expect(subject.call({}, 5)).to be_kind_of(Puppet::Pops::Types::PIntegerType)
    end
  end
end
