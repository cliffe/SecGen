require 'timeout'
require 'rubygems'
require 'process_helper'
require 'ovirtsdk4'
require_relative './print.rb'

class OVirtFunctions


  # Helper for removing VMs which Vagrant lost track of, i.e. exist but are reported as 'have not been created'.
  # @param [String] destroy_output_log -- logfile from vagrant destroy process which contains loose VMs
  # @param [String] options -- command-line opts, used for building oVirt connection
  def self.remove_uncreated_vms(destroy_output_log, options, scenario)
    retry_count = 0
    max_retries = 5
    while retry_count <= max_retries
      begin
        # Build an ovirt connection
        ovirt_connection = get_ovirt_connection(options)
        # Determine the oVirt name of the uncreated VMs and Build the oVirt VM names
        ovirt_vm_names = build_ovirt_names(scenario, options[:prefix], get_uncreated_vms(destroy_output_log))
        ovirt_vm_names.each do |vm_name|
          # Find the oVirt VM objects
          vms = vms_service(ovirt_connection).list(search: "name=#{vm_name}")
          # Shut down and remove the VMs
          vms.each do |vm|
            begin
              Timeout.timeout(60*5) do
                while vm_exists(ovirt_connection, vm)
                  shutdown_vm(ovirt_connection, vm)
                  remove_vm(ovirt_connection, vm)
                end
                Print.info 'Successfully removed VM: ' + vm.name + ' -- ID: ' + vm.id
              end
            rescue Timeout::Error
              Print.err "Error: Removal of #{vm.name} timed-out. (ID: #{vm.id})"
              next
            end
          end
        end
      rescue OvirtSDK4::Error => ex
        if retry_count < max_retries
          Print.err 'Error: Retrying... #' + (retry_count + 1).to_s + ' of #' + max_retries.to_s
        end
        retry_count += 1
        puts ex
      end
    end
  end

  def self.vm_exists(ovirt_connection, vm)
    # Check if VM has been removed
    begin
      service = vms_service(ovirt_connection).vm_service(vm.id)
      service.get
      return true
    rescue OvirtSDK4::Error => err
      if err.code == 404
        return false
      else
        puts err
        exit(1)
      end
    end
  end

  def self.vms_service(ovirt_connection)
    ovirt_connection.system_service.vms_service
  end

  def self.shutdown_vm(ovirt_connection, vm)
    service = vms_service(ovirt_connection).vm_service(vm.id)
    while service.get.status == 'up'
      service.stop
      puts 'Stopping VM: ' + vm.name
      sleep(15)
    end
  end

  def self.remove_vm(ovirt_connection, vm)
    service = vms_service(ovirt_connection).vm_service(vm.id)
    begin
      service.remove(force: true)
      puts 'Removing VM: ' + vm.name
      sleep(15)
    rescue Exception
      # ignore oVirt exception, it gets raised regardless of success / failure
    end
  end

  def self.build_ovirt_names(scenario_path, prefix, vm_names)
    ovirt_vm_names = []
    scenario_name = scenario_path.split('/').last.split('.').first
    prefix = prefix ? (prefix + '-' + scenario_name) : ('SecGen-' + scenario_name)
    vm_names.each do |vm_name|
      ovirt_vm_names << "#{prefix}-#{vm_name}".tr('_', '-')
    end
    ovirt_vm_names
  end

  def self.get_uncreated_vms(output_log)
    split = output_log.split('==> ')
    failures = []
    split.each do |line|
      if line.include? ': VM is not created. Please run `vagrant up` first.'
        failed_vm = line.split(':').first
        failures << failed_vm
      end
    end
    failures.uniq
  end

  # @param [String] options -- command-line opts, contains oVirt username, password and url
  def self.get_ovirt_connection(options)
    if options[:ovirtuser] and options[:ovirtpass] and options[:ovirturl]
      conn_attr = {}
      conn_attr[:url] = options[:ovirturl]
      conn_attr[:username] = options[:ovirtuser]
      conn_attr[:password] = options[:ovirtpass]
      conn_attr[:debug] = true
      conn_attr[:insecure] = true
      conn_attr[:headers] = {'Filter' => true}
      OvirtSDK4::Connection.new(conn_attr)
    else
      Print.err('Fatal: oVirt connections require values for the --ovirtuser and --ovirtpass command line arguments')
      exit(1)
    end
  end

end