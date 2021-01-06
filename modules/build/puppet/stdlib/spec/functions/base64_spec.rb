require 'spec_helper'

describe 'base64' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params('one').and_raise_error(Puppet::ParseError) }
  it { is_expected.to run.with_params('one', 'two').and_raise_error(Puppet::ParseError, %r{first argument must be one of}) }
  it { is_expected.to run.with_params('encode', ['two']).and_raise_error(Puppet::ParseError, %r{second argument must be a string}) }
  it { is_expected.to run.with_params('encode', 2).and_raise_error(Puppet::ParseError, %r{second argument must be a string}) }
  it { is_expected.to run.with_params('encode', 'thestring', 'three').and_raise_error(Puppet::ParseError, %r{third argument must be one of}) }
  it { is_expected.to run.with_params('decode', "dGhlc3RyaW5n\n", 'strict').and_raise_error(ArgumentError) }

  it { is_expected.to run.with_params('encode', 'thestring').and_return("dGhlc3RyaW5n\n") }
  it { is_expected.to run.with_params('decode', 'dGhlc3RyaW5n').and_return('thestring') }
  it { is_expected.to run.with_params('decode', "dGhlc3RyaW5n\n").and_return('thestring') }

  it { is_expected.to run.with_params('encode', 'thestring', 'default').and_return("dGhlc3RyaW5n\n") }
  it { is_expected.to run.with_params('decode', 'dGhlc3RyaW5n', 'default').and_return('thestring') }
  it { is_expected.to run.with_params('decode', "dGhlc3RyaW5n\n", 'default').and_return('thestring') }

  it { is_expected.to run.with_params('encode', 'thestring', 'strict').and_return('dGhlc3RyaW5n') }
  it { is_expected.to run.with_params('decode', 'dGhlc3RyaW5n', 'strict').and_return('thestring') }

  it {
    is_expected.to run.with_params('encode', 'a very long string that will cause the base64 encoder to produce output with multiple lines')
                      .and_return("YSB2ZXJ5IGxvbmcgc3RyaW5nIHRoYXQgd2lsbCBjYXVzZSB0aGUgYmFzZTY0\nIGVuY29kZXIgdG8gcHJvZHVjZSBvdXRwdXQgd2l0aCBtdWx0aXBsZSBsaW5l\ncw==\n")
  }
  it {
    is_expected.to run.with_params('decode', "YSB2ZXJ5IGxvbmcgc3RyaW5nIHRoYXQgd2lsbCBjYXVzZSB0aGUgYmFzZTY0\nIGVuY29kZXIgdG8gcHJvZHVjZSBvdXRwdXQgd2l0aCBtdWx0aXBsZSBsaW5l\ncw==\n")
                      .and_return('a very long string that will cause the base64 encoder to produce output with multiple lines')
  }
  it {
    is_expected.to run.with_params('decode', 'YSB2ZXJ5IGxvbmcgc3RyaW5nIHRoYXQgd2lsbCBjYXVzZSB0aGUgYmFzZTY0IGVuY29kZXIgdG8gcHJvZHVjZSBvdXRwdXQgd2l0aCBtdWx0aXBsZSBsaW5lcw==')
                      .and_return('a very long string that will cause the base64 encoder to produce output with multiple lines')
  }
  it {
    is_expected.to run.with_params('encode', 'a very long string that will cause the base64 encoder to produce output with multiple lines', 'strict')
                      .and_return('YSB2ZXJ5IGxvbmcgc3RyaW5nIHRoYXQgd2lsbCBjYXVzZSB0aGUgYmFzZTY0IGVuY29kZXIgdG8gcHJvZHVjZSBvdXRwdXQgd2l0aCBtdWx0aXBsZSBsaW5lcw==')
  }
  it {
    is_expected.to run.with_params('decode', 'YSB2ZXJ5IGxvbmcgc3RyaW5nIHRoYXQgd2lsbCBjYXVzZSB0aGUgYmFzZTY0IGVuY29kZXIgdG8gcHJvZHVjZSBvdXRwdXQgd2l0aCBtdWx0aXBsZSBsaW5lcw==', 'strict')
                      .and_return('a very long string that will cause the base64 encoder to produce output with multiple lines')
  }
  it {
    is_expected.to run.with_params('encode', 'https://www.google.com.tw/?gws_rd=ssl#q=hello+world', 'urlsafe')
                      .and_return('aHR0cHM6Ly93d3cuZ29vZ2xlLmNvbS50dy8_Z3dzX3JkPXNzbCNxPWhlbGxvK3dvcmxk')
  }
  it {
    is_expected.to run.with_params('decode', 'aHR0cHM6Ly93d3cuZ29vZ2xlLmNvbS50dy8_Z3dzX3JkPXNzbCNxPWhlbGxvK3dvcmxk', 'urlsafe')
                      .and_return('https://www.google.com.tw/?gws_rd=ssl#q=hello+world')
  }
  it {
    is_expected.to run.with_params('encode', 'https://github.com/puppetlabs/puppetlabs-stdlib/pulls?utf8=%E2%9C%93&q=is%3Apr+is%3Aopen+Add', 'urlsafe')
                      .and_return('aHR0cHM6Ly9naXRodWIuY29tL3B1cHBldGxhYnMvcHVwcGV0bGFicy1zdGRsaWIvcHVsbHM_dXRmOD0lRTIlOUMlOTMmcT1pcyUzQXByK2lzJTNBb3BlbitBZGQ=')
  }
  it {
    is_expected.to run.with_params('decode', 'aHR0cHM6Ly9naXRodWIuY29tL3B1cHBldGxhYnMvcHVwcGV0bGFicy1zdGRsaWIvcHVsbHM_dXRmOD0lRTIlOUMlOTMmcT1pcyUzQXByK2lzJTNBb3BlbitBZGQ=', 'urlsafe')
                      .and_return('https://github.com/puppetlabs/puppetlabs-stdlib/pulls?utf8=%E2%9C%93&q=is%3Apr+is%3Aopen+Add')
  }
end
