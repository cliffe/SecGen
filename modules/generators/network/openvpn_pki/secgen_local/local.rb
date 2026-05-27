#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'openssl'
require 'json'

class OpenvpnPki < StringGenerator
  attr_accessor :server_ip
  attr_accessor :port
  attr_accessor :vpn_subnet
  attr_accessor :vpn_subnet_mask
  attr_accessor :push_routes
  attr_accessor :num_clients

  DH_PARAMS = "-----BEGIN DH PARAMETERS-----\n" \
    "MIIBCAKCAQEAkqpMBK/OWvDaAXttYVegfVO0SjSr+CLTPFNs4EyDfNMaVHL8otYu\n" \
    "WzenpQYRtRFgxub2BwIOOPuJa64nk+IA+aTTXILQiG4cG0vTwVUUrh86Tmrt2xsD\n" \
    "YY0o6pvV5e82tGPGa4lhh7s8C+C6RDvMN1fH6CMHS2QFBaNm/Mfh5DHwCMJ0Lyrh\n" \
    "gwJit2T1Oz0vRSBqQCcPFj72dPdqKZEC1I9zOcEyAJCamj5L+JQe+QerWfxhOMkH\n" \
    "uBCa3ua/wraZExJp6OfoazSsq8Ajt6ka9128cdTUnSe9GJIx0WSpYGb3w0qfoWEL\n" \
    "kcXPz97MdvEga1dx92ybPJv7pJiWNqhLAwIBAg==\n" \
    "-----END DH PARAMETERS-----\n"

  def initialize
    super
    self.module_name = 'OpenVPN PKI Generator'
    self.server_ip = ''
    self.port = ''
    self.vpn_subnet = ''
    self.vpn_subnet_mask = ''
    self.push_routes = []
    self.num_clients = '1'
  end

  def get_options_array
    super + [['--server_ip', GetoptLong::REQUIRED_ARGUMENT],
             ['--port', GetoptLong::REQUIRED_ARGUMENT],
             ['--vpn_subnet', GetoptLong::REQUIRED_ARGUMENT],
             ['--vpn_subnet_mask', GetoptLong::REQUIRED_ARGUMENT],
             ['--push_routes', GetoptLong::REQUIRED_ARGUMENT],
             ['--num_clients', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--server_ip'
      self.server_ip << arg
    when '--port'
      self.port << arg
    when '--vpn_subnet'
      self.vpn_subnet << arg
    when '--vpn_subnet_mask'
      self.vpn_subnet_mask << arg
    when '--push_routes'
      self.push_routes << arg
    when '--num_clients'
      self.num_clients = arg
    end
  end

  def generate_ca
    key = OpenSSL::PKey::RSA.new(2048)
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 1
    cert.subject = OpenSSL::X509::Name.parse('/CN=SecGen-CA')
    cert.issuer = cert.subject
    cert.public_key = key.public_key
    cert.not_before = Time.now
    cert.not_after = Time.now + 365 * 24 * 60 * 60

    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = cert
    cert.add_extension(ef.create_extension('basicConstraints', 'CA:TRUE', true))
    cert.add_extension(ef.create_extension('keyUsage', 'cRLSign,keyCertSign', true))
    cert.sign(key, OpenSSL::Digest::SHA256.new)

    { key: key, cert: cert }
  end

  def generate_cert(cn, ca_key, ca_cert, is_server: false)
    key = OpenSSL::PKey::RSA.new(2048)
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = rand(2**32)
    cert.subject = OpenSSL::X509::Name.parse("/CN=#{cn}")
    cert.issuer = ca_cert.subject
    cert.public_key = key.public_key
    cert.not_before = Time.now
    cert.not_after = Time.now + 365 * 24 * 60 * 60

    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = ca_cert
    cert.add_extension(ef.create_extension('basicConstraints', 'CA:FALSE', true))

    if is_server
      cert.add_extension(ef.create_extension('keyUsage', 'digitalSignature,keyEncipherment', true))
      cert.add_extension(ef.create_extension('extendedKeyUsage', 'serverAuth', true))
    else
      cert.add_extension(ef.create_extension('keyUsage', 'digitalSignature', true))
      cert.add_extension(ef.create_extension('extendedKeyUsage', 'clientAuth', true))
    end

    cert.sign(ca_key, OpenSSL::Digest::SHA256.new)

    { key: key, cert: cert }
  end

  def generate
    ca = generate_ca

    server = generate_cert('secgen-server', ca[:key], ca[:cert], is_server: true)

    clients = num_clients.to_i.times.map do |i|
      client = generate_cert("secgen-client-#{i}", ca[:key], ca[:cert], is_server: false)
      {
        'client_cert' => client[:cert].to_pem,
        'client_key'  => client[:key].to_pem
      }
    end

    bundle = {
      'ca_cert'          => ca[:cert].to_pem,
      'server_cert'      => server[:cert].to_pem,
      'server_key'       => server[:key].to_pem,
      'dh_params'        => DH_PARAMS,
      'server_ip'        => server_ip,
      'port'             => port,
      'vpn_subnet'       => vpn_subnet,
      'vpn_subnet_mask'  => vpn_subnet_mask,
      'push_routes'      => push_routes,
      'clients'          => clients
    }

    self.outputs << JSON.generate(bundle)
  end
end

OpenvpnPki.new.run