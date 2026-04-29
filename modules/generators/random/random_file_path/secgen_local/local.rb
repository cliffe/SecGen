#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'fileutils'
require 'logger'

class FilePathGenerator < StringGenerator
  attr_accessor :selected_location
  attr_accessor :username

  BASE_SYSTEM_LOCATIONS = [
    '/usr/bin',
    '/etc/cron.d',
    '/opt',
    '/usr/local/bin',
    '/usr/sbin',
    '/var/tmp',
    '/usr/share',
    '/var/opt',
    '/usr/lib',
    '/srv',
    '/var/spool',
    '/usr/src',
    '/var/cache'
  ].freeze

  def initialize
    super
    self.module_name = 'Random File Path Generator'
    @logger = Logger.new($stdout)
    @logger.level = Logger::INFO
    @logger.formatter = proc do |severity, datetime, _progname, msg|
      "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
    end
    @username = nil
  end

  def get_options_array
    super + [
      ['--validate-writable', GetoptLong::OPTIONAL_ARGUMENT],
      ['--username', GetoptLong::REQUIRED_ARGUMENT]
    ]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--validate-writable'
      @validate_writable = true
    when '--username'
      @username = arg
    end
  end

  def predefined_locations
    locations = BASE_SYSTEM_LOCATIONS.dup
    if @username && !@username.empty?
      locations << "/home/#{@username}/.config"
      locations << "/home/#{@username}/.config/local"
      locations << "/home/#{@username}/.local/share"
      @logger.info("Including user-specific paths for username: #{@username}")
    else
      @logger.info("No username provided, using only system locations")
    end
    locations << "/root/.config"
    locations << "/root/.local/share"
    locations
  end

  def validate_path(path)
    unless path.is_a?(String) && !path.empty?
      @logger.error("Invalid path: path must be a non-empty string")
      return false
    end

    normalized_path = File.expand_path(path)

    unless normalized_path == path
      @logger.warn("Path '#{path}' normalized to '#{normalized_path}'")
    end

    unless predefined_locations.include?(normalized_path)
      @logger.error("Path '#{normalized_path}' is not in the predefined list of allowed locations")
      return false
    end

    @logger.info("Path validation successful for: #{normalized_path}")
    true
  end

  def check_write_permissions(path)
    return false unless validate_path(path)

    begin
      if File.directory?(path)
        if File.writable?(path)
          @logger.info("Write permission confirmed for: #{path}")
          return true
        else
          @logger.warn("No write permission for existing directory: #{path}")
        end
      else
        parent_dir = File.dirname(path)
        if File.directory?(parent_dir) && File.writable?(parent_dir)
          @logger.info("Parent directory writable, can create: #{path}")
          return true
        else
          @logger.warn("Cannot create path, parent not writable: #{parent_dir}")
        end
      end
    rescue Errno::EACCES => e
      @logger.error("Permission denied accessing: #{path} - #{e.message}")
    rescue Errno::ENOENT => e
      @logger.error("Path does not exist: #{path} - #{e.message}")
    rescue StandardError => e
      @logger.error("Unexpected error checking permissions for #{path}: #{e.message}")
    end

    false
  end

  def filter_available_locations
    locations = predefined_locations
    available = locations.select do |location|
      begin
        if File.directory?(location)
          @logger.info("Location available: #{location}")
          true
        else
          @logger.warn("Location not found (will be created): #{location}")
          true
        end
      rescue StandardError => e
        @logger.error("Error checking location #{location}: #{e.message}")
        false
      end
    end

    if available.empty?
      @logger.warn("No locations available, using fallback: /tmp")
      available = ['/tmp']
    end

    available
  end

  def select_random_location
    available_locations = filter_available_locations

    if @validate_writable
      writable_locations = available_locations.select { |loc| check_write_permissions(loc) }
      if writable_locations.empty?
        @logger.warn("No writable locations found, selecting from all available")
        writable_locations = available_locations
      end
      available_locations = writable_locations
    end

    selected = available_locations.sample
    @logger.info("=" * 60)
    @logger.info("SELECTED PATH: #{selected}")
    @logger.info("Username context: #{@username}")
    @logger.info("Selection made from #{available_locations.length} available path(s)")
    @logger.info("Available paths were: #{available_locations.join(', ')}")
    @logger.info("=" * 60)
    @logger.info("AUDIT: Random path selected at #{Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')}")
    @logger.info("AUDIT: Path: #{selected}")
    @logger.info("AUDIT: Username: #{@username}")
    @logger.info("AUDIT: Module: #{module_name}")
    @logger.info("=" * 60)

    selected
  end

  def generate
    location = select_random_location
    self.outputs << location
    self.selected_location = location
  end
end

FilePathGenerator.new.run