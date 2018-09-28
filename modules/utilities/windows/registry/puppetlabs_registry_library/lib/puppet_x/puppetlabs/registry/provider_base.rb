# This module is meant to be mixed into the registry_key AND registry_value providers.
module PuppetX
module Puppetlabs
module Registry
module ProviderBase
  def self.define_ffi(base)
    extend FFI::Library

    ffi_convention :stdcall

    # uintptr_t is defined in an FFI conf as platform specific, either
    # ulong_long on x64 or just ulong on x86
    typedef :uintptr_t, :handle
    # any time LONG / ULONG is in a win32 API definition DO NOT USE platform specific width
    # which is what FFI uses by default
    # instead create new aliases for these very special cases
    typedef :int32, :win32_long
    typedef :uint32, :win32_ulong
    typedef :uint32, :dword

    # http://msdn.microsoft.com/en-us/library/windows/desktop/ms724911(v=vs.85).aspx
    # LONG WINAPI RegQueryValueEx(
    #   _In_         HKEY hKey,
    #   _In_opt_     LPCTSTR lpValueName,
    #   _Reserved_   LPDWORD lpReserved,
    #   _Out_opt_    LPDWORD lpType,
    #   _Out_opt_    LPBYTE lpData,
    #   _Inout_opt_  LPDWORD lpcbData
    # );
    ffi_lib :advapi32
    attach_function :RegQueryValueExW,
      [:handle, :pointer, :pointer, :pointer, :pointer, :pointer], :win32_long

    # http://msdn.microsoft.com/en-us/library/windows/desktop/ms724847(v=vs.85).aspx
    # LONG WINAPI RegDeleteKeyEx(
    #   _In_        HKEY hKey,
    #   _In_        LPCTSTR lpSubKey,
    #   _In_        REGSAM samDesired,
    #   _Reserved_  DWORD Reserved
    # );
    ffi_lib :advapi32
    attach_function :RegDeleteKeyExW,
      [:handle, :pointer, :win32_ulong, :dword], :win32_long

    # https://msdn.microsoft.com/en-us/library/windows/desktop/ms724851(v=vs.85).aspx
    # LONG WINAPI RegDeleteValue(
    #   _In_      HKEY hKey,
    #   _In_opt_  LPCTSTR lpValueName
    # );
    ffi_lib :advapi32
    attach_function :RegDeleteValueW,
      [:handle, :pointer], :win32_long

    # https://msdn.microsoft.com/en-us/library/windows/desktop/ms724923(v=vs.85).aspx
    # LONG WINAPI RegSetValueEx(
    #   _In_             HKEY    hKey,
    #   _In_opt_         LPCTSTR lpValueName,
    #   _Reserved_       DWORD   Reserved,
    #   _In_             DWORD   dwType,
    #   _In_       const BYTE    *lpData,
    #   _In_             DWORD   cbData
    # );
    ffi_lib :advapi32
    attach_function :RegSetValueExW,
      [:handle, :pointer, :dword, :dword, :pointer, :dword], :win32_long

    # this duplicates code found in puppet, but necessary for backwards compat
    class << base
      # note that :uchar is aliased in Puppet to :byte
      def from_string_to_wide_string(str, &block)
        str = wide_string(str)
        FFI::MemoryPointer.new(:uchar, str.bytesize) do |ptr|
          ptr.put_array_of_uchar(0, str.bytes.to_a)

          yield ptr
        end

        # ptr has already had free called, so nothing to return
        nil
      end

      def wide_string(str)
        # if given a nil string, assume caller wants to pass a nil pointer to win32
        return nil if str.nil?
        # ruby (< 2.1) does not respect multibyte terminators, so it is possible
        # for a string to contain a single trailing null byte, followed by garbage
        # causing buffer overruns.
        #
        # See http://svn.ruby-lang.org/cgi-bin/viewvc.cgi?revision=41920&view=revision
        newstr = str + "\0".encode(str.encoding)
        newstr.encode!('UTF-16LE')
      end
    end
  end

  # This is a class method in order to be easily mocked in the spec tests.
  def self.initialize_system_api(base)
    if Puppet.features.microsoft_windows?
      begin
        require 'win32/registry'
      rescue LoadError => exc
        msg = "Could not load the required win32/registry library (ErrorID 1EAD86E3-D533-4286-BFCB-CCE8B818DDEA) [#{exc.message}]"
        Puppet.err msg
        error = Puppet::Error.new(msg)
        error.set_backtrace exc.backtrace
        raise error
      end

      begin
        require 'ffi'
        define_ffi(base)
      rescue LoadError => exc
        msg = "Could not load the required ffi library [#{exc.message}]"
        Puppet.err msg
        error = Puppet::Error.new(msg)
        error.set_backtrace exc.backtrace
        raise error
      end

      class << base
        # create instance to access mix-in methods since it doesn't use module_function
        require 'puppet/util/windows/registry'
        def RegistryHelpers
          @registry_helpers ||= Class.new.extend(Puppet::Util::Windows::Registry)
        end
      end
    end
  end

  def self.included(base)
    # Initialize the Win32 API.  This is a method call so the spec tests can
    # easily mock the initialization of the Win32 libraries on non-win32
    # systems.
    initialize_system_api(base)

    # Define an hkeys class method in the eigenclass we're being mixed into.
    # This is the one true place to define the root hives we support.
    class << base
      def hkeys
        # REVISIT: I'd like to make this easier to mock and stub.
        {
          :hkcr => Win32::Registry::HKEY_CLASSES_ROOT,
          :hklm => Win32::Registry::HKEY_LOCAL_MACHINE,
          :hku  => Win32::Registry::HKEY_USERS,
        }
      end
    end
  end

  # The rest of these methods will be mixed in as instance methods into the
  # provider class.  The path method is expected to be mixed in by the provider
  # specific module, ProviderKeyBase or ProviderValueBase
  def from_string_to_wide_string(str, &block)
    self.class.from_string_to_wide_string(str, &block)
  end

  def wide_string(str)
    self.class.wide_string(str)
  end

  def hkeys
    self.class.hkeys
  end

  def registry_helpers
    self.class.RegistryHelpers
  end

  def hive
    hkeys[path.root]
  end

  def access
    path.access
  end

  def root
    path.root
  end

  def subkey
    path.subkey
  end

  def valuename
    path.valuename
  end

  def type2name_map
    {
      Win32::Registry::REG_NONE      => :none,
      Win32::Registry::REG_SZ        => :string,
      Win32::Registry::REG_EXPAND_SZ => :expand,
      Win32::Registry::REG_BINARY    => :binary,
      Win32::Registry::REG_DWORD     => :dword,
      Win32::Registry::REG_QWORD     => :qword,
      Win32::Registry::REG_MULTI_SZ  => :array
    }
  end

  def type2name(type)
    type2name_map[type]
  end

  def name2type(name)
    name2type = {}
    type2name_map.each_pair {|k,v| name2type[v] = k}
    name2type[name]
  end

  def each_value(key, &block)
    # This problem affects Ruby 2.1 and higher by introducing locale conversion
    # unnecessary. Puppet 4 introduces it's own each_value patches to the
    # Registry abstraction to work around these problems
    # https://github.com/puppetlabs/puppet/commit/b46ede74f640a809b68a473ac8720b93b13d2ac3
    if registry_helpers.respond_to?(:each_value)
      registry_helpers.each_value(key) do |name, type, data|
        yield name, type, data
      end
    else
      key.each_value do |name, type, data|
        yield name, type, data
      end
    end
  end
end
end
end
end
