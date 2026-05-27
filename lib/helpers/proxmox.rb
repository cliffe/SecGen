require 'timeout'
require 'rubygems'
require 'process_helper'
require_relative 'proxmox_connection'
require_relative './print.rb'

class ProxmoxFunctions

  def self.provider_proxmox?(options)
    options[:proxmoxuser] and options[:proxmoxpass] and options[:proxmoxurl]
  end

  def self.create_snapshot(project_dir, vm_names, options)
    Print.std " Connecting to Proxmox"
    # Connect to Proxmox API
    connection = Proxmox::Connection.new options[:proxmoxurl]
    connection.login username: options[:proxmoxuser], password: options[:proxmoxpass]
    # get proxmox ids
    Print.std " Getting ID: #{vm_names}"
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
      ensure
        file.close if file
      end

    end
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


end
