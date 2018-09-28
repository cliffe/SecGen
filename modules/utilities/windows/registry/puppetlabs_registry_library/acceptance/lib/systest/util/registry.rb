require 'pathname'

require Pathname.new(__FILE__).dirname
# This module is meant to be mixed into the individual test cases for the
# registry module.
module Systest::Util::Registry
  FUTURE_PARSER = ENV['FUTURE_PARSER'] == 'true'

  # Given a relative path, returns an absolute path for a test file.
  # Basically, this just prepends the a unique temp dir path (specific to the
  # current test execution) to your relative path.
  def get_test_file_path(host, file_rel_path)
    File.join(host_test_tmp_dirs[host.name], file_rel_path)
  end

  def cur_test_file
    @path
  end

  def cur_test_file_shortname
    File.basename(cur_test_file, File.extname(cur_test_file))
  end

  def tmpdir(host, basename)
    host_tmpdir = host.tmpdir(basename)
    # we need to make sure that the puppet user can traverse this directory...
    chmod(host, "755", host_tmpdir)
    host_tmpdir
  end

  def mkdirs(host, dir_path)
    on(host, "mkdir -p #{dir_path}")
  end

  def chown(host, owner, group, path)
    on(host, "chown #{owner}:#{group} #{path}")
  end

  def chmod(host, mode, path)
    on(host, "chmod #{mode} #{path}")
  end

  def all_hosts
    # we need one list of all of the hosts, to assist in managing temp dirs.  It's possible
    # that the master is also an agent, so this will consolidate them into a unique set
    hosts
  end

  def host_test_tmp_dirs
    # now we can create a hash of temp dirs--one per host, and unique to this test--without worrying about
    # doing it twice on any individual host
    @host_test_tmp_dirs ||= Hash[all_hosts.map do |host|
      [host.name, tmpdir(host, cur_test_file_shortname)]
    end]
  end

  def master_manifest_dir
    @master_manifest_dir ||= "master_manifest"
  end

  def master_module_dir
    @master_module_dir ||= "master_modules"
  end

  def master_manifest_file
    @master_manifest_file ||= "#{master_manifest_dir}/site.pp"
  end

  def agent_args
    @agent_args ||= "--trace --libdir=\"%s\" --pluginsync --no-daemonize --verbose --onetime --test --server #{master}"
  end

  def agent_lib_dir
    @agent_lib_dir ||= "agent_lib"
  end

  def masters
    @masters ||= hosts.select { |host| host['roles'].include? 'master' } || []
  end

  def windows_agents
    agents.select { |agent| agent['platform'].include?('windows') }
  end

  def master_options
    @master_options ||= "--manifest=\"#{get_test_file_path(master, master_manifest_file)}\" " +
        "--modulepath=\"#{get_test_file_path(master, master_module_dir)}\" " +
        "--autosign true --pluginsync"
  end

  def master_options_hash
    @master_options_hash ||= {
        :manifest => "#{get_test_file_path(master, master_manifest_file)}",
        :modulepath => "#{get_test_file_path(master, master_module_dir)} ",
        :autosign => true,
        :pluginsync => true
    }
  end

  def agent_exit_codes
    # legal exit codes whenever we run the agent
    #  we need to allow exit code 2, which means "changes were applied" on the agent
    @agent_exit_codes ||= [0, 2]
  end

  def x64?(agent)
    on(agent, facter('architecture')).stdout.chomp == 'x64'
  end

  def native_sysdir(agent)
    if x64?(agent)
      if on(agent, 'ls /cygdrive/c/windows/sysnative', :acceptable_exit_codes => (0..255)).exit_code == 0
        '`cygpath -W`/sysnative'
      else
        nil
      end
    else
      '`cygpath -S`'
    end
  end

  def randomstring(length)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    str = ""
    1.upto(length) { |i| str << chars[rand(chars.size-1)] }
    return str
  end

  # Create a file on the host.
  # Parameters:
  # [host] the host to create the file on
  # [file_path] the path to the file to be created
  # [file_content] a string containing the contents to be written to the file
  # [options] a hash containing additional behavior options.  Currently supported:
  # * :mkdirs (default false) if true, attempt to create the parent directories on the remote host before writing
  #       the file
  # * :owner (default 'root') the username of the user that the file should be owned by
  # * :group (default 'puppet') the name of the group that the file should be owned by
  # * :mode (default '644') the mode (file permissions) that the file should be created with
  def create_test_file(host, file_rel_path, file_content, options)

    # set default options
    options[:mkdirs] ||= false
    options[:owner] ||= (host['user'] || "root")
    options[:group] ||= (host['group'] || "puppet")
    options[:mode] ||= "755"

    file_path = get_test_file_path(host, file_rel_path)

    mkdirs(host, File.dirname(file_path)) if (options[:mkdirs] == true)
    create_remote_file(host, file_path, file_content)
    #
    # NOTE: we need these `chown/chmod calls because the acceptance framework connects to the nodes as "root", but
    #  puppet 'master' runs as user 'puppet'.  Therefore, in order for puppet master to be able to read any files
    #  that we've created, we have to carefully set their permissions
    #
    chown(host, options[:owner], options[:group], file_path)
    chmod(host, options[:mode], file_path)
  end

  def puppet_module_install(host = nil, source = nil, module_name = nil, module_path = '/etc/puppet/modules')
    opts = {:source => source, :module_name => module_name, :target_module_path => module_path}
    copy_root_module_to(host, opts)
  end

  def setup_master(master_manifest_content="# Intentionally Blank\n")
    step "Setup Puppet Master Manifest" do
      proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../../../'))
      if any_hosts_as?('master') do
        masters.each do |host|
          puppet_module_install(host, proj_root, 'registry', File.join(host['puppetpath'], "modules"))
          create_test_file(host, master_manifest_file, master_manifest_content, :mkdirs => true)
          puppet_conf_update_ini = <<-MANIFEST
          ini_setting{'Update Puppet.Conf':
              ensure             => present,
              section            => 'main',
              key_val_separator  => '=',
              path               => '#{host['puppetpath']}/puppet.conf',
              setting            => 'manifestdir',
              value              => '#{host_test_tmp_dirs[host.name]}/master_manifest/' }
          MANIFEST
          on host, puppet('apply', '--debug'), :stdin => puppet_conf_update_ini
        end
      end
      end
    end
    step "Symlink the module(s) into the master modulepath" do
      if any_hosts_as?('master') do
        masters.each do |host|
          moddir = get_test_file_path(host, master_module_dir)
          mkdirs(host, moddir)
          #on host, "ln -s /opt/puppet-git-repos/stdlib \"#{moddir}/stdlib\"; ln -s /opt/puppet-git-repos/registry \"#{moddir}/registry\""
        end
      end
      end
    end
  end

  def clean_up
    step "Clean Up" do
      if any_hosts_as?(:master)
        masters.each do |host|
          puppet_conf_update_ini = <<-MANIFEST
            ini_setting{'Revert Puppet.Conf':
              ensure             => absent,
              section            => 'main',
              key_val_separator  => '=',
              path               => '#{host['puppetpath']}/puppet.conf',
              setting            => 'manifestdir' }
          MANIFEST
          on host, puppet('apply', '--debug'), :stdin => puppet_conf_update_ini
          on host, "rm -rf \"%s\"" % get_test_file_path(host, '')
        end
      end
      agents.each do |host|
        on host, "rm -rf \"%s\"" % get_test_file_path(host, '')
      end
    end
  end

  def get_apply_opts(environment_hash = nil, acceptable_exit_codes = agent_exit_codes)
    opts = {
        :catch_failures => true,
        :future_parser => FUTURE_PARSER,
        :acceptable_exit_codes => agent_exit_codes,
    }
    opts.merge!(:environment => environment_hash) if environment_hash
    opts
  end

end

