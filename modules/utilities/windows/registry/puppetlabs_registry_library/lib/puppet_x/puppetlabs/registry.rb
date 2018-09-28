module PuppetX
module Puppetlabs
module Registry
  # For 64-bit OS, use 64-bit view. Ignored on 32-bit OS
  KEY_WOW64_64KEY = 0x100
  # For 64-bit OS, use 32-bit view. Ignored on 32-bit OS
  KEY_WOW64_32KEY = 0x200 unless defined? KEY_WOW64_32KEY

  # This is the base class for Path manipulation.  This class is meant to be
  # abstract, RegistryKeyPath and RegistryValuePath will customize and override
  # this class.
  class RegistryPathBase < String
    attr_reader :path
    def initialize(path)
      @filter_path_memo = nil
      @path ||= path
      super(path)
    end

    # The path is valid if we're able to parse it without exceptions.
    def valid?
      (filter_path and true) rescue false
    end

    def canonical
      filter_path[:canonical]
    end

    # This method is meant to help setup aliases so autorequire can sort itself
    # out in a case insensitive but preserving manner.  It returns an array of
    # resource identifiers.
    def aliases
      [canonical.downcase]
    end

    def access
      filter_path[:access]
    end

    def root
      filter_path[:root]
    end

    def ascend(&block)
      p = canonical
      while idx = p.rindex('\\')
        p = p[0, idx]
        yield p
      end
    end

    private

    def filter_path
      if @filter_path_memo
        return @filter_path_memo
      end
      result = {}

      path = @path

      result[:valuename] = case path[-1, 1]
      when '\\'
        result[:is_default] = true
        ''
      else
        result[:is_default] = false
        idx = path.rindex('\\') || 0
        if idx > 0
          path[idx+1..-1]
        else
          ''
        end
      end

      # Strip off any trailing slash.
      path = path.gsub(/\\*$/, '')

      unless captures = /^(32:)?([h|H][^\\]*)((?:\\[^\\]{1,255})*)$/.match(path)
        raise ArgumentError, "Invalid registry key: #{path}"
      end

      case captures[1]
      when '32:'
        result[:access] = PuppetX::Puppetlabs::Registry::KEY_WOW64_32KEY
        result[:prefix] = '32:'
      else
        result[:access] = PuppetX::Puppetlabs::Registry::KEY_WOW64_64KEY
        result[:prefix] = ''
      end

      # canonical root key symbol
      result[:root] = case captures[2].to_s.downcase
              when /hkey_local_machine/, /hklm/
                :hklm
              when /hkey_classes_root/, /hkcr/
                :hkcr
              when /hkey_users/, /hku/
                :hku
              when /hkey_current_user/, /hkcu/,
                /hkey_current_config/, /hkcc/,
                /hkey_performance_data/,
                /hkey_performance_text/,
                /hkey_performance_nlstext/,
                /hkey_dyn_data/
                raise ArgumentError, "Unsupported predefined key: #{path}"
              else
                raise ArgumentError, "Invalid registry key: #{path}"
              end

      result[:trailing_path] = captures[3]

      result[:trailing_path].gsub!(/^\\/, '')

      if result[:trailing_path].empty?
        result[:canonical] = "#{result[:prefix]}#{result[:root].to_s}"
      else
        # Leading backslash is not part of the subkey name
        result[:canonical] = "#{result[:prefix]}#{result[:root].to_s}\\#{result[:trailing_path]}"
      end

      @filter_path_memo = result
    end
  end

  class RegistryKeyPath < RegistryPathBase
    def subkey
      filter_path[:trailing_path]
    end
  end

  class RegistryValuePath < RegistryPathBase
    def canonical
      # This method gets called in the type and the provider.  We need to
      # preserve the trailing backslash for the provider, otherwise it won't
      # think this is a default value.
      if default?
        filter_path[:canonical] << "\\"
      else
        filter_path[:canonical]
      end
    end

    def subkey
      if default?
        filter_path[:trailing_path]
      else
        filter_path[:trailing_path].gsub(/^(.*)\\.*$/, '\1')
      end
    end

    def valuename
      filter_path[:valuename]
    end

    def default?
      !!filter_path[:is_default]
    end
  end
end
end
end
