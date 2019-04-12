require 'spec_helper'

describe 'fqdn_rand_string' do
  let(:default_charset) { %r{\A[a-zA-Z0-9]{100}\z} }
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(ArgumentError, /wrong number of arguments/i) }
  it { is_expected.to run.with_params(0).and_raise_error(ArgumentError, /first argument must be a positive integer/) }
  it { is_expected.to run.with_params(1.5).and_raise_error(ArgumentError, /first argument must be a positive integer/) }
  it { is_expected.to run.with_params(-10).and_raise_error(ArgumentError, /first argument must be a positive integer/) }
  it { is_expected.to run.with_params("-10").and_raise_error(ArgumentError, /first argument must be a positive integer/) }
  it { is_expected.to run.with_params("string").and_raise_error(ArgumentError, /first argument must be a positive integer/) }
  it { is_expected.to run.with_params([]).and_raise_error(ArgumentError, /first argument must be a positive integer/) }
  it { is_expected.to run.with_params({}).and_raise_error(ArgumentError, /first argument must be a positive integer/) }
  it { is_expected.to run.with_params(1, 1).and_raise_error(ArgumentError, /second argument must be undef or a string/) }
  it { is_expected.to run.with_params(1, []).and_raise_error(ArgumentError, /second argument must be undef or a string/) }
  it { is_expected.to run.with_params(1, {}).and_raise_error(ArgumentError, /second argument must be undef or a string/) }
  it { is_expected.to run.with_params(100).and_return(default_charset) }
  it { is_expected.to run.with_params("100").and_return(default_charset) }
  it { is_expected.to run.with_params(100, nil).and_return(default_charset) }
  it { is_expected.to run.with_params(100, '').and_return(default_charset) }
  it { is_expected.to run.with_params(100, 'a').and_return(/\Aa{100}\z/) }
  it { is_expected.to run.with_params(100, 'ab').and_return(/\A[ab]{100}\z/) }
  it { is_expected.to run.with_params(100, 'ãβ').and_return(/\A[ãβ]{100}\z/) }

  it "provides the same 'random' value on subsequent calls for the same host" do
    expect(fqdn_rand_string(10)).to eql(fqdn_rand_string(10))
  end

  it "considers the same host and same extra arguments to have the same random sequence" do
    first_random = fqdn_rand_string(10, :extra_identifier => [1, "same", "host"])
    second_random = fqdn_rand_string(10, :extra_identifier => [1, "same", "host"])

    expect(first_random).to eql(second_random)
  end

  it "allows extra arguments to control the random value on a single host" do
    first_random = fqdn_rand_string(10, :extra_identifier => [1, "different", "host"])
    second_different_random = fqdn_rand_string(10, :extra_identifier => [2, "different", "host"])

    expect(first_random).not_to eql(second_different_random)
  end

  it "should return different strings for different hosts" do
    val1 = fqdn_rand_string(10, :host => "first.host.com")
    val2 = fqdn_rand_string(10, :host => "second.host.com")

    expect(val1).not_to eql(val2)
  end

  def fqdn_rand_string(max, args = {})
    host = args[:host] || '127.0.0.1'
    charset = args[:charset]
    extra = args[:extra_identifier] || []

    # workaround not being able to use let(:facts) because some tests need
    # multiple different hostnames in one context
    scope.stubs(:lookupvar).with("::fqdn", {}).returns(host)

    function_args = [max]
    if args.has_key?(:charset) or !extra.empty?
      function_args << charset
    end
    function_args += extra
    scope.function_fqdn_rand_string(function_args)
  end
end
