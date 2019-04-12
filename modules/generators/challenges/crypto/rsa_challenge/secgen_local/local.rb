#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_encoder.rb'
require 'rsa'

class RSAChallenge < StringEncoder

  def initialize
    super
    self.module_name = 'RSA Challenge Generator'
    self.strings_to_encode = ['150']
  end

  def encode(str)

    # For a challenge ee want to return n, e and c or   p, q, e and c and to have the challenger feed this into the RSA algorithm to decrypt the ciphertext.
    #
    #
    # n should be small enough to be cracked. prime factorization of n will return p and q
    #

    # 1. Choose two distinct prime numbers p and q.

    # For security purposes, the integers p and q should be chosen at random, and should be of similar bit-length.
    # Prime integers can be efficiently found using a primality test.

    # 2. Compute n = pq.


    # RSA Challenge Generator style:
    # RSA Encryption parameters. Public key: [e,N].
    # e:	65537
    # N:	793317875048486727769682005180064761
    # Cipher:	378078478708458631194952101156921202

    # PicoCTF style:
    #
    # p =  9648423029010515676590551740010426534945737639235739800643989352039852507298491399561035009163427050370107570733633350911691280297777160200625281665378483
    # q =  11874843837980297032092405848653656852760910154543380907650040190704283358909208578251063047732443992230647903887510065547947313543299303261986053486569407
    # e =  65537
    # c =  83208298995174604174773590298203639360540024871256126892889661345742403314929861939100492666605647316646576486526217457006376842280869728581726746401583705899941768214138742259689334840735633553053887641847651173776251820293087212885670180367406807406765923638973161375817392737747832762751690104423869019034
    #
    # Use RSA to find the secret message
    #

    output_data = "Solve the challenge using RSA!\n"

    value = str.to_i
    key_pair = RSA::KeyPair.generate(60)

    e = key_pair.public_key.exponent
    n = key_pair.public_key.modulus
    c = key_pair.encrypt(value)

    output_data += "e: #{e}\n"
    output_data += "n: #{n}\n"
    output_data += "ciphertext: #{c}\n"

    self.outputs << output_data
  end


  # def get_options_array
  #   super + [['--base64_image', GetoptLong::REQUIRED_ARGUMENT],
  #           ['--strings_to_leak', GetoptLong::REQUIRED_ARGUMENT]]
  # end

  # def process_options(opt, arg)
  #   super
  #   case opt
  #     when '--base64_image'
  #       self.base64_image << arg;
  #     when '--strings_to_leak'
  #       self.strings_to_leak << arg;
  #   end
  # end

  # def encoding_print_string
  #   'base64_image: <selected_image>' + print_string_padding +
  #   'strings_to_leak: ' + self.strings_to_leak.to_s
  # end
end

RSAChallenge.new.run