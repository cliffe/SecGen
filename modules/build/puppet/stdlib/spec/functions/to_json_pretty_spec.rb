require 'spec_helper'

describe 'to_json_pretty' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params([]).and_return("[\n\n]\n") }
  it { is_expected.to run.with_params(['one']).and_return("[\n  \"one\"\n]\n") }
  it { is_expected.to run.with_params(%w[one two]).and_return("[\n  \"one\",\n  \"two\"\n]\n") }
  it { is_expected.to run.with_params({}).and_return("{\n}\n") }
  it { is_expected.to run.with_params('key' => 'value').and_return("{\n  \"key\": \"value\"\n}\n") }
  it {
    is_expected.to run.with_params('one' => { 'oneA' => 'A', 'oneB' => { 'oneB1' => '1', 'oneB2' => '2' } }, 'two' => %w[twoA twoB])
                      .and_return("{\n  \"one\": {\n    \"oneA\": \"A\",\n    \"oneB\": {\n      \"oneB1\": \"1\",\n      \"oneB2\": \"2\"\n    }\n  },\n  \"two\": [\n    \"twoA\",\n    \"twoB\"\n  ]\n}\n") # rubocop:disable Metrics/LineLength : Unable to reduce line to required length
  }
  it { is_expected.to run.with_params({ 'one' => '1', 'two' => nil }, true).and_return("{\n  \"one\": \"1\"\n}\n") }
  it { is_expected.to run.with_params(['one', 'two', nil, 'three'], true).and_return("[\n  \"one\",\n  \"two\",\n  \"three\"\n]\n") }
end
