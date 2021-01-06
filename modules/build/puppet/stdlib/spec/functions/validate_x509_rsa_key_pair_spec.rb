require 'spec_helper'

describe 'validate_x509_rsa_key_pair' do
  # rubocop:disable Lint/IndentHeredoc : Heredoc's are meant to be indented in this way
  let(:valid_cert) do
    <<DOC
-----BEGIN CERTIFICATE-----
MIIC9jCCAeCgAwIBAgIRAK11n3X7aypJ7FPM8UFyAeowCwYJKoZIhvcNAQELMBIx
EDAOBgNVBAoTB0FjbWUgQ28wHhcNMTUxMTIzMjIzOTU4WhcNMTYxMTIyMjIzOTU4
WjASMRAwDgYDVQQKEwdBY21lIENvMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAz9bY/piKahD10AiJSfbI2A8NG5UwRz0r9T/WfvNVdhgrsGFgNQjvpUoZ
nNJpQIHBbgMOiXqfATFjJl5FjEkSf7GUHohlGVls9MX2JmVvknzsiitd75H/EJd+
N+k915lix8Vqmj8d1CTlbF/8tEjzANI67Vqw5QTuqebO7rkIUvRg6yiRfSo75FK1
RinCJyl++kmleBwQZBInQyg95GvJ5JTqMzBs67DeeyzskDhTeTePRYVF2NwL8QzY
htvLIBERTNsyU5i7nkxY5ptUwgFUwd93LH4Q19tPqL5C5RZqXxhE51thOOwafm+a
W/cRkqYqV+tv+j1jJ3WICyF1JNW0BQIDAQABo0swSTAOBgNVHQ8BAf8EBAMCAKAw
EwYDVR0lBAwwCgYIKwYBBQUHAwEwDAYDVR0TAQH/BAIwADAUBgNVHREEDTALggls
b2NhbGhvc3QwCwYJKoZIhvcNAQELA4IBAQAzRo0hpVTrFQZLIXpwvKwZVGvJdCkV
P95DTsSk/VTGV+/YtxrRqks++hJZnctm2PbnTsCAoIP3AMx+vicCKiKrxvpsLU8/
+6cowUbcuGMdSQktwDqbAgEhQlLsETll06w1D/KC+ejOc4+LRn3GQcEyGDtMk/EX
IeAvBZHr4/kVXWnfo6kzCLcku1f8yE/yDEFClZe9XV1Lk/s+3YfXVtNnMJJ1giZI
QVOe6CkmuQq+4AtIeW8aLkvlfp632jag1F77a1y+L268koKkj0hBMrtcErVQaxmq
xym0+soR4Tk4pTIGckeFglrLxkP2JpM/yTwSEAVlmG9vgTliYKyR0uMl
-----END CERTIFICATE-----
DOC
  end

  let(:valid_key) do
    <<DOC
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAz9bY/piKahD10AiJSfbI2A8NG5UwRz0r9T/WfvNVdhgrsGFg
NQjvpUoZnNJpQIHBbgMOiXqfATFjJl5FjEkSf7GUHohlGVls9MX2JmVvknzsiitd
75H/EJd+N+k915lix8Vqmj8d1CTlbF/8tEjzANI67Vqw5QTuqebO7rkIUvRg6yiR
fSo75FK1RinCJyl++kmleBwQZBInQyg95GvJ5JTqMzBs67DeeyzskDhTeTePRYVF
2NwL8QzYhtvLIBERTNsyU5i7nkxY5ptUwgFUwd93LH4Q19tPqL5C5RZqXxhE51th
OOwafm+aW/cRkqYqV+tv+j1jJ3WICyF1JNW0BQIDAQABAoIBADAiZ/r+xP+vkd5u
O61/lCBFzBlZQecdybJw6HJaVK6XBndA9hESUr4LHUdui6W+51ddKd65IV4bXAUk
zCKjQb+FFvLDT/bA+TTvLATUdTSN7hJJ3OWBAHuNOlQklof6JCB0Hi4+89+P8/pX
eKUgR/cmuTMDT/iaXdPHeqFbBQyA1ZpQFRjN5LyyJMS/9FkywuNc5wlpsArtc51T
gIKENUZCuPhosR+kMFc2iuTNvqZWPhvouSrmhi2O6nSqV+oy0+irlqSpCF2GsCI8
72TtLpq94Grrq0BEH5avouV+Lp4k83vO65OKCQKUFQlxz3Xkxm2U3J7KzxqnRtM3
/b+cJ/kCgYEA6/yOnaEYhH/7ijhZbPn8RujXZ5VGJXKJqIuaPiHMmHVS5p1j6Bah
2PcnqJA2IlLs3UloN+ziAxAIH6KCBiwlQ/uPBNMMaJsIjPNBEy8axjndKhKUpidg
R0OJ7RQqMShOJ8akrSfWdPtXC/GBuwCYE//t77GgZaIMO3FcT9EKA48CgYEA4Xcx
Fia0Jg9iyAhNmUOXI6hWcGENavMx01+x7XFhbnMjIKTZevFfTnTkrX6HyLXyGtMU
gHOn+k4PE/purI4ARrKO8m5wYEKqSIt4dBMTkIXXirfQjXgfjR8E4T/aPe5fOFZo
7OYuxLRtzmG1C2sW4txwKAKX1LaWcVx/RLSttSsCgYBbcj8Brk+F6OJcqYFdzXGJ
OOlf5mSMVlopyg83THmwCqbZXtw8L6kAHqZrl5airmfDSJLuOQlMDoZXW+3u3mSC
d5TwVahVUN57YDgzaumBLyMZDqIz0MZqVy23hTzkV64Rk9R0lR9xrYQJyMhw4sYL
2f0mCTsSpzz+O+t9so+i2QKBgEC38gMlwPhb2kMI/x1LZYr6uzUu5qcYf+jowy4h
KZKGwkKQj0zXFEB1FV8nvtpCP+irRmtIx6L13SYi8LnfWPzyLE4ynVdES5TfVAgd
obQOdzx+XwL8xDHCAaiWp5K3ZeXKB/xYZnxYPlzLdyh76Ond1OPnOqX4c16+6llS
c7pZAoGATd9NckT0XtXLEsF3IraDivq8dP6bccX2DNfS8UeEvRRrRwpFpSRrmuGb
jbG4yzoIX4RjQfj/z48hwhJB+cKiN9WwcPsFXtHe7v3F6BRwK0JUfrCiXad8/SGZ
KAf7Dfqi608zBdnPWHacre2Y35gPHB00nFQOLS6u46aBNSq07YA=
-----END RSA PRIVATE KEY-----
DOC
  end

  let(:another_valid_key) do
    <<DOC
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAoISxYJBTPAeAzFnm+lE/ljLlmGal2Xr3vwZKkvJiuKA/m4QJ
0ZNdtkBSDOVuG2dXVv6W4sChRtsCdvuVe7bjTYvlU8TWM3VEJDL9l9cRXScxxlKQ
Xwb35y1yV35NJfaK/jzm9KcErtQQs1RxvGlWRaohmLM8uQcuhjZfMsSlQoHQD5LX
sbPtk82RPyxYc1dj2vsaoi1VvuP2+jv4xLQOmNJY1bT5GTurqiltmxEtWhNNmGg0
2wtK00ifqLVO5HNc3gXQCDM2M99Sbmn1YtbrgsU9xMYfcPmvQvb+YoKskyoqck+c
HR//hi7vslbxABrny15LBkEfRc4TickphSGYXwIDAQABAoIBAATEzGw8/WwMIQRx
K06GeWgh7PZBHm4+m/ud2TtSXiJ0CE+7dXs3cJJIiOd/LW08/bhE6gCkjmYHfaRB
Ryicv1X/cPmzIFX5BuQ4a5ZGOmrVDkKBE27vSxAgJoR46RvWnjx9XLMp/xaekDxz
psldK8X4DvV1ZbltgDFWji947hvyqUtHdKnkQnc5j7aCIFJf9GMfzaeeDPMaL8WF
mVL4iy9EAOjNOHBshZj/OHyU5FbJ8ROwZQlCOiLCdFegftSIXt8EYDnjB3BdsALH
N6hquqrD7xDKyRbTD0K7lqxUubuMwTQpi61jZD8TBTXEPyFVAnoMpXkc0Y+np40A
YiIsR+kCgYEAyrc4Bh6fb9gt49IXGXOSRZ5i5+TmJho4kzIONrJ7Ndclwx9wzHfh
eGBodWaw5CxxQGMf4vEiaZrpAiSFeDffBLR+Wa2TFE5aWkdYkR34maDjO00m4PE1
S+YsZoGw7rGmmj+KS4qv2T26FEHtUI+F31RC1FPohLsQ22Jbn1ORipsCgYEAyrYB
J2Ncf2DlX1C0GfxyUHQOTNl0V5gpGvpbZ0WmWksumYz2kSGOAJkxuDKd9mKVlAcz
czmN+OOetuHTNqds2JJKKJy6hJbgCdd9aho3dId5Xs4oh4YwuFQiG8R/bJZfTlXo
99Qr02L7MmDWYLmrR3BA/93UPeorHPtjqSaYU40CgYEAtmGfWwokIglaSDVVqQVs
3YwBqmcrla5TpkMLvLRZ2/fktqfL4Xod9iKu+Klajv9ZKTfFkXWno2HHL7FSD/Yc
hWwqnV5oDIXuDnlQOse/SeERb+IbD5iUfePpoJQgbrCQlwiB0TNGwOojR2SFMczf
Ai4aLlQLx5dSND9K9Y7HS+8CgYEAixlHQ2r4LuQjoTs0ytwi6TgqE+vn3K+qDTwc
eoods7oBWRaUn1RCKAD3UClToZ1WfMRQNtIYrOAsqdveXpOWqioAP0wE5TTOuZIo
GiWxRgIsc7TNtOmNBv+chCdbNP0emxdyjJUIGb7DFnfCw47EjHnn8Guc13uXaATN
B2ZXgoUCgYAGa13P0ggUf5BMJpBd8S08jKRyvZb1CDXcUCuGtk2yEx45ern9U5WY
zJ13E5z9MKKO8nkGBqrRfjJa8Xhxk4HKNFuzHEet5lvNE7IKCF4YQRb0ZBhnb/78
+4ZKjFki1RrWRNSw9TdvrK6qaDKgTtCTtfRVXAYQXUgq7lSFOTtL3A==
-----END RSA PRIVATE KEY-----
DOC
  end
  # rubocop:enable Layout/IndentHeredoc

  let(:valid_cert_but_indented) do
    valid_cert.gsub(%r{^}, '  ')
  end

  let(:valid_key_but_indented) do
    valid_key.gsub(%r{^}, '  ')
  end

  let(:malformed_cert) do
    truncate_middle(valid_cert)
  end

  let(:malformed_key) do
    truncate_middle(valid_key)
  end

  let(:bad_cert) do
    'foo'
  end

  let(:bad_key) do
    'bar'
  end

  context 'with function signature validation' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
    it { is_expected.to run.with_params(0, 1, 2, 3).and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  end

  context 'with valid input' do
    describe 'valid certificate and key' do
      it { is_expected.to run.with_params(valid_cert, valid_key) }
    end
  end

  context 'with bad input' do
    describe 'valid certificate, valid but indented key' do
      it { is_expected.to run.with_params(valid_cert, valid_key_but_indented).and_raise_error(Puppet::ParseError, %r{Not a valid RSA key}) }
    end

    describe 'valid certificate, malformed key' do
      it { is_expected.to run.with_params(valid_cert, malformed_key).and_raise_error(Puppet::ParseError, %r{Not a valid RSA key}) }
    end

    describe 'valid certificate, bad key' do
      it { is_expected.to run.with_params(valid_cert, bad_key).and_raise_error(Puppet::ParseError, %r{Not a valid RSA key}) }
    end

    describe 'valid but indented certificate, valid key' do
      it { is_expected.to run.with_params(valid_cert_but_indented, valid_key).and_raise_error(Puppet::ParseError, %r{Not a valid x509 certificate}) }
    end

    describe 'malformed certificate, valid key' do
      it { is_expected.to run.with_params(malformed_cert, valid_key).and_raise_error(Puppet::ParseError, %r{Not a valid x509 certificate}) }
    end

    describe 'bad certificate, valid key' do
      it { is_expected.to run.with_params(bad_cert, valid_key).and_raise_error(Puppet::ParseError, %r{Not a valid x509 certificate}) }
    end

    describe 'validate certificate and key; certficate not signed by key' do
      it { is_expected.to run.with_params(valid_cert, another_valid_key).and_raise_error(Puppet::ParseError, %r{Certificate signature does not match supplied key}) }
    end

    describe 'valid cert and key but arguments in wrong order' do
      it { is_expected.to run.with_params(valid_key, valid_cert).and_raise_error(Puppet::ParseError, %r{Not a valid x509 certificate}) }
    end

    describe 'non-string arguments' do
      it { is_expected.to run.with_params({}, {}).and_raise_error(Puppet::ParseError, %r{is not a string}) }
      it { is_expected.to run.with_params(1, 1).and_raise_error(Puppet::ParseError, %r{is not a string}) }
      it { is_expected.to run.with_params(true, true).and_raise_error(Puppet::ParseError, %r{is not a string}) }
      it { is_expected.to run.with_params('foo', {}).and_raise_error(Puppet::ParseError, %r{is not a string}) }
      it { is_expected.to run.with_params(1, 'bar').and_raise_error(Puppet::ParseError, %r{is not a string}) }
      it { is_expected.to run.with_params('baz', true).and_raise_error(Puppet::ParseError, %r{is not a string}) }
    end
  end

  def truncate_middle(string)
    chars_to_truncate = 48
    middle = (string.length / 2).floor
    start_pos = middle - (chars_to_truncate / 2)
    end_pos = middle + (chars_to_truncate / 2)

    string[start_pos...end_pos] = ''
    string
  end
end
