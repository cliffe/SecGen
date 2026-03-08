#!/usr/bin/ruby
$: << File.expand_path("../../lib", __FILE__)
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'packetfu'
require 'faker'
require 'rubygems'

class PcapGenerator < StringEncoder
  attr_accessor :strings_to_leak

  def initialize
    super
    self.module_name = 'PCAP Generator / Builder'
    self.strings_to_leak = []
  end

  def packetgen(type, data)
    if type == 'tcp'
        # Create TCP Packet
        pkt = PacketFu::TCPPacket.new
        pkt.tcp_dst=rand(1..1023)
    elsif type == 'udp'
        # Create UDP Packet
        pkt = PacketFu::UDPPacket.new
        pkt.udp_dst=rand(1..1023)
    end
    # Create fake mac addresses for sender and receiver
    pkt.eth_saddr=Faker::Internet.mac_address
    pkt.eth_daddr=Faker::Internet.mac_address
    # Create fake Public IP addresses for sender and receiver
    pkt.ip_src=PacketFu::Octets.new.read_quad(Faker::Internet.ip_v4_address)
    pkt.ip_dst=PacketFu::Octets.new.read_quad(Faker::Internet.ip_v4_address)
    pkt.payload = data
    pkt.recalc
  end

  def datagen
    data_types = [
        Faker::Games::Dota.quote,
        Faker::Movies::BackToTheFuture.quote,
        Faker::TvShows::BojackHorseman.quote,
        Faker::ChuckNorris.fact,
        Faker::TvShows::DrWho.quote,
        Faker::TvShows::FamilyGuy.quote,
        Faker::TvShows::Friends.quote,
        Faker::TvShows::GameOfThrones.quote,
        Faker::Movies::HitchhikersGuideToTheGalaxy.quote,
        Faker::TvShows::HowIMetYourMother.quote,
        Faker::Movies::Lebowski.quote,
        Faker::Quote.most_interesting_man_in_the_world,
        Faker::TvShows::RickAndMorty.quote,
        Faker::TvShows::Simpsons.quote,
        Faker::TvShows::StrangerThings.quote,
        Faker::TvShows::TheITCrowd.quote
    ]
    data_types.sample.dump.to_s
  end

  def encode_all
    # Create an array of packets
    random_number = rand (26..75)
    count = 0
    @pcaps = []

    # Generate 25 initial packets
    25.times do
        packet_type = ['tcp', 'udp'].sample
        pkt = packetgen(packet_type, datagen)
        @pcaps << pkt
        count += 1
    end

    # Now generate random packets till we get to our random_number
    while count < random_number
        packet_type = ['tcp', 'udp'].sample
        pkt = packetgen(packet_type, datagen)
        @pcaps << pkt
        count += 1
    end

    # Now add our strings_to_leak packet
    strings = self.strings_to_leak.join("\n")
    pkt = packetgen(packet_type, strings)
    @pcaps << pkt
    count += 1

    # Finish generating packets till we have 100
    while count < 101
        packet_type = ['tcp', 'udp'].sample
        pkt = packetgen(packet_type, datagen)
        @pcaps << pkt
        count += 1
    end
    # Put packets in pcap file and return contents.
    file_contents = ''
    pfile = PacketFu::PcapFile.new
    # Use temp directory and create a unique filename to avoid conflicts
    pcap_file_path = "#{TMP_DIR}/packet_#{Process.pid}_#{Time.now.to_i}.pcap"
    res = pfile.array_to_file(:filename => pcap_file_path, :array => @pcaps, :append => true)
    file_contents = File.binread(pcap_file_path)
    File.delete(pcap_file_path)
    self.outputs << Base64.strict_encode64(file_contents)
  end

  def get_options_array
    super + [['--strings_to_leak', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--strings_to_leak'
        self.strings_to_leak << arg;
    end
  end

  def encoding_print_string
    'strings_to_leak: ' + self.strings_to_leak.to_s
  end
end

PcapGenerator.new.run