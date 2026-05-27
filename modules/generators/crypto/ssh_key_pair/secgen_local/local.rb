#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'sshkey'
class SSHKeyPairGenerator < StringEncoder

  def initialize
    super
    self.module_name = 'SSH Key Pair Generator'
  end

  def encode_all
    key = SSHKey.generate(type: "RSA", bits: 2048)
    self.outputs << {'private' => key.private_key, 'public' => key.ssh_public_key}.to_json
  end

end

SSHKeyPairGenerator.new.run
