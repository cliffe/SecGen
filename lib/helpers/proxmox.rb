require 'json'
require 'timeout'
require 'rubygems'
require 'process_helper'
require_relative 'proxmox_connection'
require_relative './print.rb'

class ProxmoxFunctions

  def self.provider_proxmox?(options)
    options[:proxmoxuser] and options[:proxmoxpass] and options[:proxmoxurl]
  end

  # Snapshots each VM as "original". Returns the names of VMs it failed on.
  def self.create_snapshot(project_dir, vm_names, options)
    Print.std " Connecting to Proxmox"
    # Connect to Proxmox API
    connection = Proxmox::Connection.new options[:proxmoxurl]
    connection.login username: options[:proxmoxuser], password: options[:proxmoxpass]
    # get proxmox ids
    Print.std " Getting ID: #{vm_names}"
    failed = []
    vm_names.each do |vm_name|
      id_path = "#{project_dir}/.vagrant/machines/#{vm_name}/proxmox/id"
      Print.std id_path
      begin
        # Open the file for reading
        file = File.open(id_path, 'r')
        node, id = file.read.split('/')

        Print.std " Creating snapshot for #{node}/#{id}"
        connection.snapshot_qemu_vm(id, node)
      rescue => e
        Print.err "Error: Failed to create snapshot: #{e.message}"
        failed << vm_name
      ensure
        file.close if file
      end

    end
    failed
  end

  # Hard-stops each VM (its running state is about to be thrown away) and rolls
  # it back to the "original" snapshot, then deletes the snapshot unless keep.
  # Returns the names of VMs it could not roll back.
  def self.rollback_snapshots(project_dir, vm_names, options, keep: true)
    connection = connect(options)
    failed = []
    vm_ids(project_dir, vm_names).each do |vm_name, node, vm_id|
      begin
        connection.stop_vm(vm_id) if connection.get_vm_state(vm_id) == :running
        Print.std " Rolling back #{vm_name} (#{node}/#{vm_id}) to snapshot original"
        connection.rollback_qemu_snapshot(vm_id, node)
      rescue StandardError => e
        Print.err " Failed to roll back #{vm_name} (#{node}/#{vm_id}): #{e.message}"
        failed << vm_name
        next
      end
      next if keep
      begin
        Print.std " Deleting snapshot original of #{vm_name} (#{node}/#{vm_id})"
        connection.delete_qemu_snapshot(vm_id, node)
      rescue StandardError => e
        # The VM is clean; a leftover snapshot only costs disk space.
        Print.err " Failed to delete snapshot of #{vm_name} (#{node}/#{vm_id}): #{e.message}"
      end
    end
    failed
  end

  def self.teardown_provisioning_nic(project_dir, vm_names, options)
    Print.std " Connecting to Proxmox"
    connection = Proxmox::Connection.new options[:proxmoxurl]
    connection.login username: options[:proxmoxuser], password: options[:proxmoxpass]

    vm_names.each do |vm_name|
      id_path = "#{project_dir}/.vagrant/machines/#{vm_name}/proxmox/id"
      Print.std id_path
      begin
        file = File.open(id_path, 'r')
        node, vm_id = file.read.split('/')

        Print.std " Stopping #{node}/#{vm_id} for NIC teardown"
        connection.stop_vm(vm_id)

        Print.std " Removing provisioning NIC (net0) from #{node}/#{vm_id}"
        connection.config_clone(node: node, vm_type: :qemu, params: { vmid: vm_id, delete: 'net0' })

        Print.std " NIC teardown complete for #{node}/#{vm_id}"
      rescue => e
        Print.err "Error: Failed to teardown provisioning NIC: #{e.message}"
      ensure
        file.close if file
      end
    end
  end

  # Applies the settings modules asked for (test_context.json's proxmox_vm_config).
  # QEMU reads these when it starts, so call this while the VMs are stopped.
  def self.apply_vm_config(project_dir, vm_names, options)
    context_path = "#{project_dir}/test_context.json"
    return unless File.exist?(context_path)

    configs = JSON.parse(File.read(context_path))['systems'].to_a.each_with_object({}) do |system, wanted|
      wanted[system['name']] = system['proxmox_vm_config'] unless system['proxmox_vm_config'].to_h.empty?
    end
    return if configs.empty?

    connection = connect(options)
    vm_ids(project_dir, vm_names).each do |vm_name, node, vm_id|
      next unless configs[vm_name]
      begin
        Print.std " Setting #{configs[vm_name]} on #{vm_name} (#{node}/#{vm_id})"
        params = configs[vm_name].map { |option, value| [option.to_sym, value] }.to_h.merge(vmid: vm_id)
        connection.config_clone(node: node, vm_type: :qemu, params: params)
      rescue StandardError => e
        Print.err "Error: Failed to apply VM settings to #{vm_name}: #{e.message}"
      end
    end
  end

  def self.start_vms(project_dir, vm_names, options)
    Print.std " Connecting to Proxmox"
    connection = Proxmox::Connection.new options[:proxmoxurl]
    connection.login username: options[:proxmoxuser], password: options[:proxmoxpass]

    vm_names.each do |vm_name|
      id_path = "#{project_dir}/.vagrant/machines/#{vm_name}/proxmox/id"
      Print.std id_path
      begin
        file = File.open(id_path, 'r')
        node, vm_id = file.read.split('/')

        Print.std " Starting #{vm_name} (#{node}/#{vm_id})"
        connection.start_vm(vm_id)
      rescue => e
        Print.err "Error: Failed to start VM #{vm_name}: #{e.message}"
      ensure
        file.close if file
      end
    end
  end

  # [[vm_name, node, vm_id]] for the VMs vagrant created (those with an id file).
  def self.vm_ids(project_dir, vm_names)
    vm_names.map do |vm_name|
      id_path = "#{project_dir}/.vagrant/machines/#{vm_name}/proxmox/id"
      next nil unless File.exist?(id_path)
      node, vm_id = File.read(id_path).strip.split('/')
      [vm_name, node, vm_id]
    end.compact
  end

  def self.connect(options)
    connection = Proxmox::Connection.new options[:proxmoxurl]
    connection.login username: options[:proxmoxuser], password: options[:proxmoxpass]
    connection
  end

  # Waits (up to timeout seconds in total) for each VM's guest agent to answer.
  # Returns the names of VMs whose agent never did; their tests will SKIP.
  def self.wait_for_agents(project_dir, vm_names, options, timeout)
    connection = connect(options)
    deadline = Time.now + timeout
    missing = []
    vm_ids(project_dir, vm_names).each do |vm_name, node, vm_id|
      loop do
        up = begin
          connection.qemu_agent_running?(vm_id, node)
        rescue StandardError
          false
        end
        if up
          Print.std " Guest agent up on #{vm_name} (#{node}/#{vm_id})"
          break
        end
        if Time.now > deadline
          Print.err " Guest agent on #{vm_name} (#{node}/#{vm_id}) did not answer within #{timeout}s"
          missing << vm_name
          break
        end
        sleep 10
      end
    end
    missing
  end

  # Graceful shutdown, falling back to a hard stop.
  def self.shutdown_vms(project_dir, vm_names, options)
    connection = connect(options)
    vm_ids(project_dir, vm_names).each do |vm_name, node, vm_id|
      begin
        next unless connection.get_vm_state(vm_id) == :running
        Print.std " Shutting down #{vm_name} (#{node}/#{vm_id})"
        connection.shutdown_vm(vm_id)
      rescue StandardError => e
        Print.err " Shutdown of #{vm_name} failed (#{e.message}); stopping it"
        connection.stop_vm(vm_id) rescue Print.err(" Failed to stop #{vm_name}")
      end
    end
  end

  # Stops and deletes the project's VMs through the API (works whatever state
  # vagrant thinks they are in, e.g. after net0 teardown). Returns the names of
  # VMs that still exist afterwards.
  def self.destroy_vms(project_dir, vm_names, options)
    connection = connect(options)
    remaining = []
    vm_ids(project_dir, vm_names).each do |vm_name, node, vm_id|
      begin
        state = connection.get_vm_state(vm_id)
        if state == :not_created
          Print.std " #{vm_name} (#{node}/#{vm_id}) already gone"
          next
        end
        if state == :running
          Print.std " Stopping #{vm_name} (#{node}/#{vm_id})"
          connection.stop_vm(vm_id)
        end
        Print.std " Deleting #{vm_name} (#{node}/#{vm_id})"
        connection.delete_vm(vm_id)
        connection.vm_info_cache.delete(vm_id)
        remaining << vm_name unless connection.get_vm_state(vm_id) == :not_created
      rescue StandardError => e
        Print.err " Failed to delete #{vm_name} (#{node}/#{vm_id}): #{e.message}"
        remaining << vm_name
      end
    end
    remaining
  end


end
