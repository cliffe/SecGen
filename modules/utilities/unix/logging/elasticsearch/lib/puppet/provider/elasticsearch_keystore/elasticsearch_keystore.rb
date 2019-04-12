Puppet::Type.type(:elasticsearch_keystore).provide(
  :elasticsearch_keystore
) do
  desc 'Provider for `elasticsearch-keystore` based secret management.'

  def self.defaults_dir
    @defaults_dir ||= case Facter.value('osfamily')
                      when 'RedHat'
                        '/etc/sysconfig'
                      else
                        '/etc/default'
                      end
  end

  def self.home_dir
    @home_dir ||= case Facter.value('osfamily')
                  when 'OpenBSD'
                    '/usr/local/elasticsearch'
                  else
                    '/usr/share/elasticsearch'
                  end
  end

  attr_accessor :defaults_dir, :home_dir

  commands :keystore => "#{home_dir}/bin/elasticsearch-keystore"

  def self.run_keystore(args, instance, configdir = '/etc/elasticsearch', stdin = nil)
    options = {
      :custom_environment => {
        'ES_INCLUDE' => File.join(defaults_dir, "elasticsearch-#{instance}"),
        'ES_PATH_CONF' => "#{configdir}/#{instance}"
      },
      :uid => 'elasticsearch',
      :gid => 'elasticsearch'
    }

    unless stdin.nil?
      stdinfile = Tempfile.new('elasticsearch-keystore')
      stdinfile << stdin
      stdinfile.flush
      options[:stdinfile] = stdinfile.path
    end

    begin
      stdout = execute([command(:keystore)] + args, options)
    ensure
      unless stdin.nil?
        stdinfile.close
        stdinfile.unlink
      end
    end

    stdout.exitstatus.zero? ? stdout : raise(Puppet::Error, stdout)
  end

  def self.present_keystores
    Dir[File.join(%w[/ etc elasticsearch *])].select do |directory|
      File.exist? File.join(directory, 'elasticsearch.keystore')
    end.map do |instance|
      settings = run_keystore(['list'], File.basename(instance)).split("\n")
      {
        :name => File.basename(instance),
        :ensure => :present,
        :provider => name,
        :settings => settings
      }
    end
  end

  def self.instances
    present_keystores.map do |keystore|
      new keystore
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov
      end
    end
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def flush
    case @property_flush[:ensure]
    when :present
      debug(self.class.run_keystore(['create'], resource[:name], resource[:configdir]))
      @property_flush[:settings] = resource[:settings]
    when :absent
      File.delete(File.join([
        '/', 'etc', 'elasticsearch', resource[:instance], 'elasticsearch.keystore'
      ]))
    end

    # Note that since the property is :array_matching => :all, we have to
    # expect that the hash is wrapped in an array.
    if @property_flush[:settings] and not @property_flush[:settings].first.empty?
      # Flush properties that _should_ be present
      @property_flush[:settings].first.each_pair do |setting, value|
        next unless @property_hash[:settings].nil? \
          or not @property_hash[:settings].include? setting
        debug(self.class.run_keystore(
          ['add', '--force', '--stdin', setting], resource[:name], resource[:configdir], value
        ))
      end

      # Remove properties that are no longer present
      if resource[:purge] and not (@property_hash.nil? or @property_hash[:settings].nil?)
        (@property_hash[:settings] - @property_flush[:settings].first.keys).each do |setting|
          debug(self.class.run_keystore(
            ['remove', setting], resource[:name], resource[:configdir]
          ))
        end
      end
    end

    @property_hash = self.class.present_keystores.detect do |u|
      u[:name] == resource[:name]
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  # settings property setter
  #
  # @return [Hash] settings
  def settings=(new_settings)
    @property_flush[:settings] = new_settings
  end

  # settings property getter
  #
  # @return [Hash] settings
  def settings
    @property_hash[:settings]
  end

  # Sets the ensure property in the @property_flush hash.
  #
  # @return [Symbol] :present
  def create
    @property_flush[:ensure] = :present
  end

  # Determine whether this resource is present on the system.
  #
  # @return [Boolean]
  def exists?
    @property_hash[:ensure] == :present
  end

  # Set flushed ensure property to absent.
  #
  # @return [Symbol] :absent
  def destroy
    @property_flush[:ensure] = :absent
  end
end
