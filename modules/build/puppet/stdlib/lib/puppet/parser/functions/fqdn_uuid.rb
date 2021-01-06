require 'digest/sha1'
#
# fqdn_uuid.rb
#
module Puppet::Parser::Functions
  newfunction(:fqdn_uuid, :type => :rvalue, :doc => <<-DOC) do |args|
    Creates a UUID based on a given string, assumed to be the FQDN

    For example, to generate a UUID based on the FQDN of a system:

    Usage:

      $uuid = fqdn_uuid($::fqdn)

    The generated UUID will be the same for the given hostname

    The resulting UUID is returned on the form:

      1d839dea-5e10-5243-88eb-e66815bd7d5c

    (u.e. without any curly braces.)

    The generated UUID is a version 5 UUID with the V5 DNS namespace:

      6ba7b810-9dad-11d1-80b4-00c04fd430c8

    This only supports a the V5 SHA-1 hash, using the DNS namespace.

    Please consult http://www.ietf.org/rfc/rfc4122.txt for the details on
    UUID generation and example implementation.

    No verification is present at the moment as whether the domain name given
    is in fact a correct fully-qualified domain name.  Therefore any arbitrary
    string and/or alpha-numeric value can subside for a domain name.
    DOC

    raise(ArgumentError, 'fqdn_uuid: No arguments given') if args.empty?
    raise(ArgumentError, "fqdn_uuid: Too many arguments given (#{args.length})") unless args.length == 1
    fqdn = args[0]

    # Code lovingly taken from
    # https://github.com/puppetlabs/marionette-collective/blob/master/lib/mcollective/ssl.rb

    # This is the UUID version 5 type DNS name space which is as follows:
    #
    #  6ba7b810-9dad-11d1-80b4-00c04fd430c8
    #
    uuid_name_space_dns = [0x6b,
                           0xa7,
                           0xb8,
                           0x10,
                           0x9d,
                           0xad,
                           0x11,
                           0xd1,
                           0x80,
                           0xb4,
                           0x00,
                           0xc0,
                           0x4f,
                           0xd4,
                           0x30,
                           0xc8].map { |b| b.chr }.join

    sha1 = Digest::SHA1.new
    sha1.update(uuid_name_space_dns)
    sha1.update(fqdn)

    # first 16 bytes..
    bytes = sha1.digest[0, 16].bytes.to_a

    # version 5 adjustments
    bytes[6] &= 0x0f
    bytes[6] |= 0x50

    # variant is DCE 1.1
    bytes[8] &= 0x3f
    bytes[8] |= 0x80

    bytes = [4, 2, 2, 2, 6].map do |i|
      bytes.slice!(0, i).pack('C*').unpack('H*')
    end

    bytes.join('-')
  end
end
