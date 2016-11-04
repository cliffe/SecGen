require 'rubygems'

class GemExec

  # Gems that include executables (vagrant and librarian-puppet) don't always have
  # predictable executable names
  # This resolves the execuable path and starts the command
  # @param [Object] gem_name -- such as 'vagrant', 'puppet', 'librarian-puppet'
  # @param [Object] working_dir -- the location for output
  # @param [Object] argument -- the command to send 'init', 'install'
  def self.exe(gem_name, working_dir, argument)
    Print.std "Loading #{gem_name} (#{argument}) in #{working_dir}"

    version = '>= 0'
    begin
      gem_path = Gem.bin_path(gem_name, gem_name, version)
    rescue Exception => e
      # test if the program is already installed via package management
      gem_path = `which #{gem_name}`.chomp
      unless File.file? gem_path
        Print.err "Executable for #{gem_name} not found: #{e.message}"
        # vagrant can be executed via the gem path, but not installed this way
        unless gem_name == 'vagrant' || gem_name == 'packer'
          Print.err "Installing #{gem_name} gem by running 'sudo gem install #{gem_name}'..."
          system "sudo gem install #{gem_name}"
          begin
            gem_path = Gem.bin_path(gem_name, gem_name, version)
          rescue Exception => ex
            Print.err "Gem executable for #{gem_name} still not found: #{ex.message}"
          end
        end
      end
    end

    if gem_name == 'vagrant'

    end

    Dir.chdir(working_dir)
    system "#{gem_path} #{argument}"

  end
end
