require 'puppet/provider/package'
require 'pathname'
require Pathname.new(__FILE__).dirname + '../../../' + 'puppet_x/chocolatey/chocolatey_install'

Puppet::Type.type(:package).provide(:chocolatey, :parent => Puppet::Provider::Package) do

  desc "Manages packages using Chocolatey (Windows package manager).

    The syntax for Chocolatey using the puppet provider is a much
    closer match to *nix package managers, bringing a more agnostic
    approach to package management across platforms. Chocolatey packages
    usually contain all of the logic to install software silently on a
    Windows machine, much like RPM (yum) or DPKG (apt).

    Installs can be as simple as

      package {'git':
        ensure => latest,
      }

    See the ReadMe for more information."

  confine     :operatingsystem => :windows
  has_feature :installable
  has_feature :uninstallable
  has_feature :upgradeable
  has_feature :versionable
  has_feature :install_options
  has_feature :uninstall_options
  has_feature :holdable
  #has_feature :package_settings

  def initialize(value={})
    super(value)
    @compiled_choco = nil
  end

  def self.file_exists?(path)
    File.exist?(path)
  end

  def self.chocolatey_command
    if Puppet::Util::Platform.windows?
      #default_location = $::choco_installpath || ENV['ALLUSERSPROFILE'] + '\chocolatey'
      chocopath = ('C:\ProgramData\chocolatey' if file_exists?('C:\ProgramData\chocolatey\bin\choco.exe')) ||
          (ENV['ChocolateyInstall'] if ENV['ChocolateyInstall'] && file_exists?("#{ENV['ChocolateyInstall']}\\bin\\choco.exe")) ||
          ('C:\Chocolatey' if file_exists?('C:\Chocolatey\bin\choco.exe')) ||
          "#{ENV['ALLUSERSPROFILE']}\\chocolatey"

      chocopath += '\bin\choco.exe'
    else
      chocopath = 'choco.exe'
    end

    chocopath
  end

  def self.compiled_choco=(value)
    @compiled_choco = value
  end

  # this ultimately determines if we are on the C# version of choco
  # so commands can be adjusted accordingly
  def self.choco_exe?
    # call `choco -v` one time here and cache the result
    # - new choco will output a single value e.g. `0.9.9`
    # - old choco is going to return the default output e.g. `Please run chocolatey /?`
    if @compiled_choco.nil?
      execpipe(choco_ver_cmd) do |process|
        process.each_line do |line|
          line.chomp!
          if line.empty?; next; end
          if line.match(/Please run chocolatey.*/)
            @compiled_choco = false
          else
            @compiled_choco = true
          end
        end
      end
    end

    @compiled_choco
  end

  def self.choco_ver_cmd
    args = []
    args << '-v'

    [command(:chocolatey), *args]
  end

  def self.set_env_chocolateyinstall
    ENV['ChocolateyInstall'] = PuppetX::Chocolatey::ChocolateyInstall.install_path
  end

  def choco_exe?
    self.class.choco_exe?
  end

  commands :chocolatey => chocolatey_command

  def print()
    notice("The value is: '${name}'")
  end

  def install
    self.class.set_env_chocolateyinstall

    # always unhold on install
    unhold if choco_exe?

    args = []

    # also will need to address -sidebyside or -m in the install args to allow
    # multiple versions to be installed.
    args << 'install'

    should = @resource.should(:ensure)
    case should
    when true, false, Symbol
      args << @resource[:name][/\A\S*/]
    else
      args.clear
      if choco_exe?
        args << 'upgrade'
      else
        args << 'update'
      end

      # Add the package version
      args << @resource[:name][/\A\S*/] << '-version' << @resource[:ensure]
    end

    if choco_exe?
      args << '-y'
    end

    args << @resource[:install_options]

    if @resource[:source]
      args << '-source' << @resource[:source]
    end

    chocolatey(*args)
  end

  def uninstall
    self.class.set_env_chocolateyinstall

    # always unhold on uninstall
    unhold if choco_exe?

    args = 'uninstall', @resource[:name][/\A\S*/]

    if choco_exe?
      args << '-fy'
    end

    args << @resource[:uninstall_options]

    unless choco_exe?
      if @resource[:source]
        args << '-source' << @resource[:source]
      end
    end

    chocolatey(*args)
  end

  def update
    self.class.set_env_chocolateyinstall

    # always unhold on upgrade
    unhold if choco_exe?

    if choco_exe?
      args = 'upgrade', @resource[:name][/\A\S*/], '-y'
    else
      args = 'update', @resource[:name][/\A\S*/]
    end

    args << @resource[:install_options]

    if @resource[:source]
      args << '-source' << @resource[:source]
    end

    if self.query
      chocolatey(*args)
    else
      self.install
    end
  end

  # from puppet-dev mailing list
  # Puppet will call the query method on the instance of the package
  # provider resource when checking if the package is installed already or
  # not.
  # It's a determination for one specific package, the package modeled by
  # the resource the method is called on.
  # Query provides the information for the single package identified by @Resource[:name].
  def query
    self.class.instances.each do |package|
      return package.properties if @resource[:name][/\A\S*/].downcase == package.name.downcase
    end

    return nil
  end

  def self.listcmd
    args = []
    args << 'list'
    args << '-lo'
    if choco_exe?
      args << '-r'
    end

    [command(:chocolatey), *args]
  end

  def self.instances
    packages = []
    set_env_chocolateyinstall
    begin
      pins = []
      pin_output = nil unless choco_exe?
      #don't add -r yet, as there is an issue in 0.9.9.9/0.9.9.10 that returns full list plus pins
      pin_output = Puppet::Util::Execution.execute([command(:chocolatey), 'pin', 'list']) if choco_exe?
      unless pin_output.nil?
        pin_output.split("\n").each { |pin| pins << pin.split('|')[0] }
      end

      execpipe(listcmd) do |process|
        process.each_line do |line|
          line.chomp!
          if line.empty? or line.match(/Reading environment variables.*/); next; end
          if choco_exe?
            values = line.split('|')
          else
            values = line.split(' ')
          end
          values[1] = :held if pins.include? values[0]
          packages << new({ :name => values[0].downcase, :ensure => values[1], :provider => self.name })
        end
      end
    rescue Puppet::ExecutionFailure
      return nil
    end

    packages
  end

  def latestcmd
    if choco_exe?
      args = 'upgrade', '--noop', @resource[:name][/\A\S*/], '-r'
    else
      args = 'version', @resource[:name][/\A\S*/]
    end

    if @resource[:source]
      args << '-source' << @resource[:source]
    end

    unless choco_exe?
      args << '| findstr /R "latest" | findstr /V "latestCompare"'
    end

    [command(:chocolatey), *args]
  end

  def latest
    package_ver = ''
    self.class.set_env_chocolateyinstall
    begin
      execpipe(latestcmd) do |process|
        process.each_line do |line|
          line.chomp!
          if line.empty?; next; end
          if choco_exe?
            values = line.split('|')
            package_ver = values[2]
          else
            # Example: ( latest        : 2013.08.19.155043 )
            values = line.split(':').collect(&:strip).delete_if(&:empty?)
            package_ver = values[1]
          end
        end
      end
    rescue Puppet::ExecutionFailure
      return nil
    end

    package_ver
  end

  def hold
    raise ArgumentError, 'Only choco v0.9.9+ can use ensure => held' unless choco_exe?

    install

    args = 'pin', 'add', '-n', @resource[:name][/\A\S*/]

    chocolatey(*args)
  end

  def unhold
    return unless choco_exe?

    Puppet::Util::Execution.execute([command(:chocolatey), 'pin','remove', '-n', @resource[:name][/\A\S*/]], :failonfail => false)
  end


end
