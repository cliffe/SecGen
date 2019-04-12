$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))
require 'puppet/util/es_instance_validator'

# This file contains a provider for the resource type `es_instance_conn_validator`,
# which validates the Elasticsearch instance connection by attempting an https connection.

Puppet::Type.type(:es_instance_conn_validator).provide(:tcp_port) do
  desc "A provider for the resource type `es_instance_conn_validator`,
        which validates the  connection by attempting an https
        connection to the Elasticsearch instance."

  def exists?
    start_time = Time.now
    timeout = resource[:timeout]

    success = validator.attempt_connection

    while success == false && ((Time.now - start_time) < timeout)
      # It can take several seconds for the Elasticsearch instance to start up;
      # especially on the first install.  Therefore, our first connection attempt
      # may fail.  Here we have somewhat arbitrarily chosen to retry every 2
      # seconds until the configurable timeout has expired.
      Puppet.debug('Failed to connect to the Elasticsearch instance; sleeping 2 seconds before retry')
      sleep 2
      success = validator.attempt_connection
    end

    if success
      Puppet.debug("Connected to the ES instance in #{Time.now - start_time} seconds.")
    else
      Puppet.notice("Failed to connect to the ES instance within timeout window of #{timeout} seconds; giving up.")
    end

    success
  end

  def create
    # If `#create` is called, that means that `#exists?` returned false, which
    # means that the connection could not be established... so we need to
    # cause a failure here.
    raise Puppet::Error, "Unable to connect to ES instance ! (#{@validator.instance_server}:#{@validator.instance_port})"
  end

  private

  # @api private
  def validator
    @validator ||= Puppet::Util::EsInstanceValidator.new(resource[:server], resource[:port])
  end
end
