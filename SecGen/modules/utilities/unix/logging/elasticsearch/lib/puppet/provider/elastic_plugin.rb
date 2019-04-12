$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))

require 'uri'
require 'puppet_x/elastic/es_versioning'
require 'puppet_x/elastic/plugin_parsing'

# Generalized parent class for providers that behave like Elasticsearch's plugin
# command line tool.
# rubocop:disable Metrics/ClassLength
class Puppet::Provider::ElasticPlugin < Puppet::Provider
  # Elasticsearch's home directory.
  #
  # @return String
  def homedir
    case Facter.value('osfamily')
    when 'OpenBSD'
      '/usr/local/elasticsearch'
    else
      '/usr/share/elasticsearch'
    end
  end

  def exists?
    # First, attempt to list whether the named plugin exists by finding a
    # plugin descriptor file, which each plugin should have. We must wildcard
    # the name to match meta plugins, see upstream issue for this change:
    # https://github.com/elastic/elasticsearch/pull/28022
    properties_files = Dir[File.join(@resource[:plugin_dir], plugin_path, '**', '*plugin-descriptor.properties')]
    return false if properties_files.empty?

    begin
      # Use the basic name format that the plugin tool supports in order to
      # determine the version from the resource name.
      plugin_version = Puppet_X::Elastic.plugin_version(@resource[:name])

      # Naively parse the Java .properties file to check version equality.
      # Because we don't have the luxury of installing arbitrary gems, perform
      # simple parse with a degree of safety checking in the call chain
      #
      # Note that x-pack installs "meta" plugins which bundle multiple plugins
      # in one. Therefore, we need to find the first "sub" plugin that
      # indicates which version of x-pack this is.
      properties = properties_files.sort.map do |prop_file|
        IO.readlines(prop_file).map(&:strip).reject do |line|
          line.start_with?('#') or line.empty?
        end.map do |property|
          property.split('=')
        end.reject do |pairs|
          pairs.length != 2
        end.to_h
      end.find { |prop| prop.key? 'version' }

      if properties and properties['version'] != plugin_version
        debug "Elasticsearch plugin #{@resource[:name]} not version #{plugin_version}, reinstalling"
        destroy
        return false
      end
    rescue ElasticPluginParseFailure
      debug "Failed to parse plugin version for #{@resource[:name]}"
    end

    # If there is no version string, we do not check version equality
    debug "No version found in #{@resource[:name]}, not enforcing any version"
    true
  end

  def plugin_path
    @resource[:plugin_path] || Puppet_X::Elastic.plugin_name(@resource[:name])
  end

  # Intelligently returns the correct installation arguments for version 1
  # version of Elasticsearch.
  #
  # @return [Array<String>]
  #   arguments to pass to the plugin installation utility
  def install1x
    if !@resource[:url].nil?
      [
        Puppet_X::Elastic.plugin_name(@resource[:name]),
        '--url',
        @resource[:url]
      ]
    elsif !@resource[:source].nil?
      [
        Puppet_X::Elastic.plugin_name(@resource[:name]),
        '--url',
        "file://#{@resource[:source]}"
      ]
    else
      [@resource[:name]]
    end
  end

  # Intelligently returns the correct installation arguments for version 2
  # version of Elasticsearch.
  #
  # @return [Array<String>]
  #   arguments to pass to the plugin installation utility
  def install2x
    if !@resource[:url].nil?
      [@resource[:url]]
    elsif !@resource[:source].nil?
      ["file://#{@resource[:source]}"]
    else
      [@resource[:name]]
    end
  end

  # Format proxy arguments for consumption by the elasticsearch plugin
  # management tool (i.e., Java properties).
  #
  # @return Array
  #   of flags for command-line tools
  def proxy_args(url)
    parsed = URI(url)
    %w[http https].map do |schema|
      [:host, :port, :user, :password].map do |param|
        option = parsed.send(param)
        "-D#{schema}.proxy#{param.to_s.capitalize}=#{option}" unless option.nil?
      end
    end.flatten.compact
  end

  # Install this plugin on the host.
  # rubocop:disable Metrics/CyclomaticComplexity
  def create
    commands = []
    commands += proxy_args(@resource[:proxy]) if is2x? and @resource[:proxy]
    commands << 'install'
    commands << '--batch' if batch_capable?
    commands += is1x? ? install1x : install2x
    debug("Commands: #{commands.inspect}")

    retry_count = 3
    retry_times = 0
    begin
      with_environment do
        plugin(commands)
      end
    rescue Puppet::ExecutionFailure => e
      retry_times += 1
      debug("Failed to install plugin. Retrying... #{retry_times} of #{retry_count}")
      sleep 2
      retry if retry_times < retry_count
      raise "Failed to install plugin. Received error: #{e.inspect}"
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  # Remove this plugin from the host.
  def destroy
    with_environment do
      plugin(['remove', Puppet_X::Elastic.plugin_name(@resource[:name])])
    end
  end

  # Determine the installed version of Elasticsearch on this host.
  def es_version
    Puppet_X::Elastic::EsVersioning.version(
      resource[:elasticsearch_package_name], resource.catalog
    )
  end

  def is1x?
    Puppet::Util::Package.versioncmp(es_version, '2.0.0') < 0
  end

  def is2x?
    (Puppet::Util::Package.versioncmp(es_version, '2.0.0') >= 0) && \
      (Puppet::Util::Package.versioncmp(es_version, '3.0.0') < 0)
  end

  def batch_capable?
    Puppet::Util::Package.versioncmp(es_version, '2.2.0') >= 0
  end

  # Run a command wrapped in necessary env vars
  def with_environment(&block)
    env_vars = {
      'ES_JAVA_OPTS' => @resource[:java_opts],
      'ES_PATH_CONF' => @resource[:configdir]
    }
    saved_vars = {}

    unless @resource[:java_home].nil? or @resource[:java_home] == ''
      env_vars['JAVA_HOME'] = @resource[:java_home]
    end

    if !is2x? and @resource[:proxy]
      env_vars['ES_JAVA_OPTS'] += proxy_args(@resource[:proxy])
    end

    env_vars['ES_JAVA_OPTS'] = env_vars['ES_JAVA_OPTS'].join(' ')

    env_vars.each do |env_var, value|
      saved_vars[env_var] = ENV[env_var]
      ENV[env_var] = value
    end

    ret = block.yield

    saved_vars.each do |env_var, value|
      ENV[env_var] = value
    end

    ret
  end
end
