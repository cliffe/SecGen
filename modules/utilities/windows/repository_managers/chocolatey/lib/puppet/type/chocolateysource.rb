require 'puppet/type'
require 'pathname'

Puppet::Type.newtype(:chocolateysource) do

  @doc = <<-'EOT'
    Allows managing sources for Chocolatey. A source can be a
    folder, a CIFS share, a NuGet Http OData feed, or a full
    Package Gallery. Learn more about sources at
    https://chocolatey.org/docs/how-to-host-feed

  EOT

  ensurable do
    newvalue(:present)  { provider.create }
    newvalue(:disabled) { provider.disable }
    newvalue(:absent)   { provider.destroy }
    defaultto :present

    def retrieve
      provider.properties[:ensure]
    end

  end

  newparam(:name) do
    desc "The name of the source. Used for uniqueness."

    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty name must be specified."
      end
    end

    isnamevar

    munge do |value|
      value.downcase
    end

    def insync?(is)
      is.downcase == should.downcase
    end
  end

  newproperty(:location) do
    desc "The location of the source repository. Can be a url pointing to
      an OData feed (like chocolatey/chocolatey_server), a CIFS (UNC) share,
      or a local folder. Required when `ensure => present` (the default for
      `ensure`)."

    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty location must be specified."
      end
    end

    def insync?(is)
      is.downcase == should.downcase
    end
  end

  newproperty(:user) do
    desc "Optional user name for authenticated feeds.
      Requires at least Chocolatey v0.9.9.0.
      Defaults to `nil`. Specifying an empty value is the
      same as setting the value to nil or not specifying
      the property at all."

    def insync?(is)
      is.downcase == should.downcase
    end

    defaultto ''
  end

  newparam(:password) do
    desc "Optional user password for authenticated feeds.
      Not ensurable. Value is not able to be checked
      with current value. If you need to update the password,
      update another setting as well.
      Requires at least Chocolatey v0.9.9.0.
      Defaults to `nil`. Specifying an empty value is the
      same as setting the value to nil or not specifying
      the property at all."

    defaultto ''
  end

  newproperty(:priority) do
    desc "Optional priority for explicit feed order when
      searching for packages across multiple feeds.
      The lower the number the higher the priority.
      Sources with a 0 priority are considered no priority
      and are added after other sources with a priority
      number.
      Requires at least Chocolatey v0.9.9.9.
      Defaults to 0."

    validate do |value|
      if value.nil?
        raise ArgumentError, "A non-empty priority must be specified."
      end
      raise ArgumentError, "An integer is necessary for priority. Specify 0 or remove for no priority." unless resource.is_numeric?(value)
    end

    defaultto(0)
  end

  validate do
    if (!self[:user].nil? && self[:user].strip != '' && (self[:password].nil? || self[:password] == '')) || ((self[:user].nil? || self[:user].strip == '') && !self[:password].nil? && self[:password] != '')
      raise ArgumentError, "If specifying user/password, you must specify both values."
    end

    if provider.respond_to?(:validate)
      provider.validate
    end
  end

  autorequire(:exec) do
    ['install_chocolatey_official']
  end

  def munge_boolean(value)
    case value
      when true, "true", :true
        :true
      when false, "false", :false
        :false
      else
        fail("munge_boolean only takes booleans")
    end
  end

  def is_numeric?(value)
    # this is what stdlib does. Not sure if we want to emulate or not.
    #numeric = %r{^-?(?:(?:[1-9]\d*)|0)$}
    #if value.is_a? Integer or (value.is_a? String and value.match numeric)
    Float(value) != nil rescue false
  end
end
