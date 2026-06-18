#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'json'
require 'securerandom'

class MalTrailDataGenerator < StringGenerator
  attr_accessor :data_volume
  attr_accessor :embedded_flag

  # TLDs for malicious-looking domains
  TLDS = ['.com', '.net', '.xyz', '.ru', '.cn', '.info', '.pw', '.top', '.ml', '.tk']

  # Prefixes that look suspicious
  PREFIXES = ['update', 'cdn', 'api', 'mail', 'secure', 'auth', 'login', 'download',
              'verify', 'account', 'admin', 'panel', 'config', 'backup', 'db']

  # Suffixes that suggest malicious intent
  SUFFIXES = ['malware', 'bot', 'trojan', 'crypto', 'apt', 'c2', 'shell', 'payload',
              ' exploit', 'hack', 'ransom', 'miner', 'phish', 'spam', 'ddos']

  # Threat types with references
  THREAT_TYPES = [
    { info: 'known_attacker', ref: 'abuseipdb' },
    { info: 'malware_c2', ref: '(static)' },
    { info: 'trojan', ref: 'malc0de' },
    { info: 'cryptominer', ref: 'minerchk' },
    { info: 'phishing', ref: 'openphish' },
    { info: 'apt', ref: '(static)' },
    { info: 'spam', ref: 'spamhaus' },
    { info: 'botnet', ref: 'zeustracker' },
    { info: 'ransomware', ref: '(static)' },
    { info: 'c2', ref: 'emergingthreats' }
  ]

  # Common ports for different traffic types
  PORTS = {
    http: [80, 8080, 8000, 8888],
    https: [443, 8443],
    dns: [53],
    ssh: [22],
    ftp: [21],
    smtp: [25, 587],
    custom: [4444, 5555, 6666, 7777, 9999]
  }

  def initialize
    super
    self.module_name = 'MalTrail Randomized Data Generator'
    self.data_volume = 'medium'
    self.embedded_flag = ''
  end

  def get_options_array
    super + [
      ['--data_volume', GetoptLong::REQUIRED_ARGUMENT],
      ['--embedded_flag', GetoptLong::REQUIRED_ARGUMENT]
    ]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--data_volume'
      self.data_volume = arg
    when '--embedded_flag'
      self.embedded_flag = arg
    end
  end

  def generate
    # Validate and normalize data_volume
    volume = normalize_volume(self.data_volume)

    # Determine event count based on volume
    event_count = get_event_count(volume)

    # Generate events
    events = []
    (1..event_count).each do
      events << generate_random_event
    end

    # Generate the flag event
    flag_event = generate_flag_event if self.embedded_flag && !self.embedded_flag.empty?

    # Add flag event to events (inserted at a random position)
    if flag_event
      insert_position = rand(events.length)
      events.insert(insert_position, flag_event)
    end

    # Generate custom trails
    custom_trails = generate_custom_trails(events, flag_event)

    # Build output structure
    output = {
      events: events,
      custom_trails: custom_trails
    }

    output[:flag_event] = flag_event if flag_event

    # Output as JSON
    self.outputs << JSON.generate(output)
  end

  private

  def normalize_volume(volume)
    case volume.to_s.downcase
    when 'low'
      'low'
    when 'high'
      'high'
    else
      'medium'
    end
  end

  def get_event_count(volume)
    case volume
    when 'low'
      rand(10..20)
    when 'high'
      rand(500..1000)
    else # medium
      rand(50..100)
    end
  end

  def generate_random_event
    threat = THREAT_TYPES.sample
    src_ip = random_private_ip
    dst_ip = random_public_ip
    proto = ['TCP', 'UDP'].sample
    port_type = proto == 'TCP' ? [:http, :https, :ssh, :custom].sample : [:dns, :custom].sample
    dst_port = PORTS[port_type].sample
    src_port = rand(1024..65535)

    # Determine trail type and trail value
    trail_type = rand(0..2) == 0 ? 'URL' : (rand(0..1) == 0 ? 'IP' : 'DNS')
    trail = case trail_type
            when 'IP'
              dst_ip
            when 'DNS'
              random_malicious_domain
            when 'URL'
              random_malicious_url(dst_ip)
            end

    {
      timestamp: generate_timestamp,
      sensor: 'maltrail',
      src_ip: src_ip,
      src_port: src_port,
      dst_ip: dst_ip,
      dst_port: dst_port,
      proto: proto,
      trail_type: trail_type,
      trail: trail,
      trail_info: threat[:info],
      reference: threat[:ref]
    }
  end

  def generate_flag_event
    return nil if self.embedded_flag.empty?

    # Create a suspicious-looking domain that contains the flag
    flag_domain = "update.flag.local"

    {
      timestamp: generate_timestamp,
      sensor: 'maltrail',
      src_ip: random_private_ip,
      src_port: rand(1024..65535),
      dst_ip: '8.8.8.8',  # Google DNS - makes it look like a DNS query
      dst_port: 53,
      proto: 'UDP',
      trail_type: 'DNS',
      trail: flag_domain,
      trail_info: self.embedded_flag,
      reference: 'flag'
    }
  end

  def generate_custom_trails(events, flag_event)
    trails = []

    # Add header comment
    trails << '# Custom trails for training scenario'
    trails << '# Malicious IPs'

    # Extract unique IPs from events
    ip_trails = events.select { |e| e[:trail_type] == 'IP' }
                      .map { |e| "#{e[:trail]} #{e[:trail_info]} #{e[:reference]}" }
                      .uniq
                      .take(5)  # Limit to 5 IP entries
    trails.concat(ip_trails)

    trails << '# Malicious domains'

    # Extract unique domains from events
    dns_trails = events.select { |e| e[:trail_type] == 'DNS' }
                       .map { |e| "#{e[:trail]} #{e[:trail_info]} #{e[:reference]}" }
                       .uniq
                       .take(5)  # Limit to 5 domain entries
    trails.concat(dns_trails)

    # Add flag trail if present
    if flag_event
      trails << '# CTF flag trail'
      trails << "#{flag_event[:trail]} #{flag_event[:trail_info]} #{flag_event[:reference]}"
    end

    trails << '# Malicious URLs'

    # Extract unique URLs from events
    url_trails = events.select { |e| e[:trail_type] == 'URL' }
                       .map { |e| "#{e[:trail]} #{e[:trail_info]} #{e[:reference]}" }
                       .uniq
                       .take(3)  # Limit to 3 URL entries
    trails.concat(url_trails)

    trails
  end

  def random_private_ip
    case rand(3)
    when 0
      "192.168.#{rand(1..254)}.#{rand(1..254)}"
    when 1
      "10.#{rand(0..255)}.#{rand(0..255)}.#{rand(1..254)}"
    else
      "172.#{rand(16..31)}.#{rand(0..255)}.#{rand(1..254)}"
    end
  end

  def random_public_ip
    loop do
      first = rand(1..223)
      # Skip private ranges
      next if first == 10
      next if first == 127  # Loopback
      next if first == 172 && rand(0..255) >= 16 && rand(0..255) <= 31
      next if first == 192 && rand(0..255) == 168

      return "#{first}.#{rand(0..255)}.#{rand(0..255)}.#{rand(1..254)}"
    end
  end

  def random_malicious_domain
    prefix = PREFIXES.sample
    suffix = SUFFIXES.sample
    tld = TLDS.sample
    number = rand(100..999)

    "#{prefix}-#{suffix}#{number}#{tld}"
  end

  def random_malicious_url(ip = nil)
    domain = random_malicious_domain
    paths = ['update.exe', 'download/payload.zip', 'install.msi', 'setup.bin',
             'config.jar', 'update.sh', 'backup.tar.gz']

    if rand(2) == 0 && ip
      "http://#{ip}/#{paths.sample}"
    else
      "http://#{domain}/#{paths.sample}"
    end
  end

  def generate_timestamp
    # Generate a timestamp within the last 24 hours
    now = Time.now
    random_seconds = rand(0..86400)  # Within last 24 hours
    time = now - random_seconds
    time.strftime('%Y-%m-%d %H:%M:%S.%6N')
  end
end

MalTrailDataGenerator.new.run