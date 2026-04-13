#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'openssl'

class SelfSignedCertGenerator < StringEncoder

  attr_accessor :domain, :strings_to_leak, :uri, :key_size, :days

  def initialize
    super
    self.module_name     = 'Self-Signed TLS Certificate Generator'
    self.domain          = 'localhost'
    self.strings_to_leak = []
    self.uri             = ''
    self.key_size        = 2048
    self.days            = 365
  end

  def encode_all
    cn = self.strings_to_leak[0] || self.domain

    key = OpenSSL::PKey::RSA.new(self.key_size)

    cert = OpenSSL::X509::Certificate.new
    cert.version    = 2
    cert.serial     = rand(1_000_000_000)
    cert.not_before = Time.now
    cert.not_after  = Time.now + (self.days * 24 * 60 * 60)

    subject = OpenSSL::X509::Name.parse("/CN=#{cn}/O=SecGen Lab/OU=Netsec")
    cert.subject    = subject
    cert.issuer     = subject
    cert.public_key = key.public_key

    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate  = cert

    san_entries = ["DNS:#{self.domain}"]
    normalised_uri = self.uri.end_with?('/') ? self.uri : "#{self.uri}/"
    san_entries << "URI:#{normalised_uri}" if self.uri && !self.uri.empty?

    cert.add_extension(ef.create_extension('subjectAltName', san_entries.join(','), false))
    cert.add_extension(ef.create_extension('basicConstraints', 'CA:FALSE', false))

    cert.sign(key, OpenSSL::Digest::SHA256.new)

    self.outputs << {'cert_pem' => cert.to_pem, 'key_pem' => key.to_pem, 'cn' => cn}.to_json
  end

  def process_options(opt, arg)
    super
    case opt
    when '--domain'
      self.domain = arg
    when '--strings_to_leak'
      self.strings_to_leak << arg
    when '--uri'
      self.uri = arg
    when '--key_size'
      self.key_size = arg.to_i
    when '--days'
      self.days = arg.to_i
    end
  end

  def get_options_array
    super + [
      ['--domain',          GetoptLong::REQUIRED_ARGUMENT],
      ['--strings_to_leak', GetoptLong::REQUIRED_ARGUMENT],
      ['--uri',         GetoptLong::REQUIRED_ARGUMENT],
      ['--key_size',        GetoptLong::REQUIRED_ARGUMENT],
      ['--days',            GetoptLong::REQUIRED_ARGUMENT],
    ]
  end

  def encoding_print_string
    "domain: #{self.domain}, cn: #{self.strings_to_leak[0]}, uri: #{self.uri}"
  end

end

SelfSignedCertGenerator.new.run