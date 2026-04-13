#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'open3'

class SSHKeyPairGenerator < StringEncoder

  def initialize
    super
    self.module_name = 'GPG Key Pair Generator'
  end

  def encode_all
    # TODO: Incorporate some way of making this key import temporary... We don't want to fill our host systems keyring up with a million keys.
    _, gen_stderr, _ = Open3.capture3("gpg --batch --gen-key #{GENERATORS_DIR}key/gpg_key_pair/files/parameterfile")
    key_id = gen_stderr.split("\n").last.split(" ")[2]

    privkey_stdout, _, _ = Open3.capture3("gpg --armor --export-secret-keys #{key_id}")
    pubkey_stdout, _, _ = Open3.capture3("gpg --armor --export #{key_id}")

    self.outputs << {'private' => privkey_stdout, 'public' => pubkey_stdout}.to_json
  end

end

SSHKeyPairGenerator.new.run
