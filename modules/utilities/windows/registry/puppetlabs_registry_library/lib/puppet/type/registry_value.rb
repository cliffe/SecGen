require 'puppet/type'
begin
  require "puppet_x/puppetlabs/registry"
rescue LoadError => detail
  require 'pathname' # JJM WORK_AROUND #14073 and #7788
  require Pathname.new(__FILE__).dirname + "../../" + "puppet_x/puppetlabs/registry"
end

Puppet::Type.newtype(:registry_value) do
  @doc = <<-EOT
    Manages registry values on Windows systems.

    The `registry_value` type can manage registry values.  See the
    `type` and `data` attributes for information about supported
    registry types, e.g. REG_SZ, and how the data should be specified.

    **Autorequires:** Any parent registry key managed by Puppet will be
    autorequired.
  EOT

  def self.title_patterns
    [[/^(.*?)\Z/m, [[:path, lambda { |x| x }]]]]
  end

  ensurable

  newparam(:path, :namevar => true) do
    desc "The path to the registry value to manage.  For example:
      'HKLM\Software\Value1', 'HKEY_LOCAL_MACHINE\Software\Vendor\Value2'.
      If Puppet is running on a 64-bit system, the 32-bit registry key can
      be explicitly manage using a prefix.  For example:
      '32:HKLM\Software\Value3'"

    validate do |path|
      PuppetX::Puppetlabs::Registry::RegistryValuePath.new(path).valid?
    end
    munge do |path|
      reg_path = PuppetX::Puppetlabs::Registry::RegistryValuePath.new(path)
      # Windows is case insensitive and case preserving.  We deal with this by
      # aliasing resources to their downcase values.  This is inspired by the
      # munge block in the alias metaparameter.
      if @resource.catalog
        reg_path.aliases.each do |alt_name|
          @resource.catalog.alias(@resource, alt_name)
        end
      else
        Puppet.debug "Resource has no associated catalog.  Aliases are not being set for #{@resource.to_s}"
      end
      reg_path.canonical
    end
  end

  newproperty(:type) do
    desc "The Windows data type of the registry value.  Puppet provides
      helpful names for these types as follows:

      * string => REG_SZ
      * array  => REG_MULTI_SZ
      * expand => REG_EXPAND_SZ
      * dword  => REG_DWORD
      * qword  => REG_QWORD
      * binary => REG_BINARY

    "
    newvalues(:string, :array, :dword, :qword, :binary, :expand)
    defaultto :string
  end

  newproperty(:data, :array_matching => :all) do
    desc "The data stored in the registry value.  Data should be specified
     as a string value but may be specified as a Puppet array when the
     type is set to `array`."

    defaultto ''

    munge do |value|
      case resource[:type]
      when :dword
        val = Integer(value) rescue nil
        fail("The data must be a valid DWORD: #{value}") unless val and (val.abs >> 32) <= 0
        val
      when :qword
        val = Integer(value) rescue nil
        fail("The data must be a valid QWORD: #{value}") unless val and (val.abs >> 64) <= 0
        val
      when :binary
        if (value.respond_to?(:length) && value.length == 1) || (value.kind_of?(Integer) && value <= 9)
          value = "0#{value}"
        end
        unless value.match(/^([a-f\d]{2} ?)*$/i)
          fail("The data must be a hex encoded string of the form: '00 01 02 ...'")
        end
        # First, strip out all spaces from the string in the manfest.  Next,
        # put a space after each pair of hex digits.  Strip off the rightmost
        # space if it's present.  Finally, downcase the whole thing.  The final
        # result should be: "CaFE BEEF" => "ca fe be ef"
        value.gsub(/\s+/, '').gsub(/([0-9a-f]{2})/i) { "#{$1} " }.rstrip.downcase
      else #:string, :expand, :array
        value
      end
    end

    def property_matches?(current, desired)
      case resource[:type]
      when :binary
        return false unless current
        current.casecmp(desired) == 0
      else
        super(current, desired)
      end
    end

    def change_to_s(currentvalue, newvalue)
      if currentvalue.respond_to? :join
        currentvalue = currentvalue.join(",")
      end
      if newvalue.respond_to? :join
        newvalue = newvalue.join(",")
      end
      super(currentvalue, newvalue)
    end
  end

  # Autorequire the nearest ancestor registry_key found in the catalog.
  autorequire(:registry_key) do
    req = []
    # This is a value path and not a key path because it's based on the path of
    # the value resource.
    path = PuppetX::Puppetlabs::Registry::RegistryValuePath.new(value(:path))
    # It is important to match against the downcase value of the path because
    # other resources are expected to alias themselves to the downcase value so
    # that we respect the case insensitive and preserving nature of Windows.
    if found = path.enum_for(:ascend).find { |p| catalog.resource(:registry_key, p.to_s.downcase) }
      req << found.to_s.downcase
    end
    req
  end
end
