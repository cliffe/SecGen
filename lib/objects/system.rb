require 'json'

class System

  attr_accessor :name
  attr_accessor :attributes # (basebox selection)
  attr_accessor :base_platform # (unix/linux/windows)
  attr_accessor :module_selectors # (filters)
  attr_accessor :module_selections # (after resolution)
  attr_accessor :num_actioned_module_conflicts

  # Initalizes System object
  # @param [Object] name of the system
  # @param [Object] attributes such as base box selection
  # @param [Object] module_selectors these are modules that define filters for selecting the actual modules to use
  def initialize(name, attributes, module_selectors)
    self.name = name
    self.attributes = attributes
    self.module_selectors = module_selectors
    self.module_selections = []
    self.num_actioned_module_conflicts = 0
  end

  # selects from the available modules, based on the selection filters that have been specified
  # @param [Object] available_modules all available modules (vulnerabilities, services, bases)
  # @return [Object] the list of selected modules
  def resolve_module_selection(available_modules)
    retry_count = 0
    begin

      selected_modules = []
      self.num_actioned_module_conflicts = 0

      # for each module specified in the scenario
      module_selectors.each do |module_filter|
        selected_modules += select_modules(module_filter.module_type, module_filter.attributes, available_modules, selected_modules, module_filter.unique_id, module_filter.write_output_variable, module_filter.write_to_module_with_id, module_filter.received_inputs)
        if selected_modules.size == 1  # First iteration, the base box
          base_box = selected_modules[0]
          self.base_platform = base_box.attributes['platform'][0]
          if base_platform == 'windows'
            selected_modules += get_windows_build_modules(available_modules)
          end
        end
      end
      selected_modules

    rescue RuntimeError=>e
      # When the scenario fails to be resolved
      # bruteforce conflict resolution (could be more intelligent)

      Print.err 'Failed to resolve scenario.'
      if self.num_actioned_module_conflicts > 0
        Print.err "During scenario generation #{num_actioned_module_conflicts} module conflict(s) occured..."
      else
        Print.err 'No conflicts, but failed to resolve scenario -- this is a sign there is something wrong in the config (scenario / modules)'
        Print.err 'Please review the scenario -- something is wrong.'
        exit
      end
      if retry_count < RETRIES_LIMIT
        Print.err "Re-attempting to resolve scenario (##{retry_count + 1})..."
        sleep 1
        retry_count += 1
        retry
      else
        Print.err "Tried re-randomising #{RETRIES_LIMIT} times. Still no joy."
        Print.err 'Please review the scenario -- something is wrong.'
        exit
      end
    end
  end

  # returns a list containing a module (plus dependencies recursively) of the module type with the required attributes
  # modules are selected from the list of available modules and will be checked against previously selected modules for conflicts
  # raises an exception when unable to resolve and the retry limit has not been reached
  def select_modules(module_type, required_attributes, available_modules, previously_selected_modules, unique_id, write_outputs_to, write_to_module_with_id, received_inputs)
    # select based on selected type, access, cve...

    search_list = available_modules.clone
    # shuffle order of available vulnerabilities
    search_list.shuffle!

    # remove any module that is not the type of module we are adding (vulnerabilty/service)
    if module_type != 'any'
      search_list.delete_if{|x|
        x.module_type != module_type
      }
    end

    # filter to those that satisfy the attribute filters
    search_list.delete_if{|module_for_possible_exclusion|
      !module_for_possible_exclusion.matches_attributes_requirement(required_attributes)
    }
    Print.verbose "Filtered to modules matching: #{required_attributes.inspect} ~= (n=#{search_list.size})"

    # remove non-options due to conflicts
    search_list.delete_if{|module_for_possible_exclusion|
      check_conflicts_with_list(module_for_possible_exclusion, previously_selected_modules)
    }

    if search_list.length == 0
      raise 'failed'
      Print.err 'Could not find a matching module. Please check the scenario specification'
    else
      # use from the top of the randomised list
      selected = search_list[0].clone
      Print.verbose "Selecting module: #{selected.printable_name}"

      # propagate module relationships established when the filter was created
      selected.write_output_variable = write_outputs_to
      selected.write_to_module_with_id = write_to_module_with_id
      selected.unique_id = unique_id
      # propagate any literal values passed in via the scenario
      selected.received_inputs = received_inputs

      # feed through the input from any previous module's output
      previously_selected_modules.each do |previous_module|
        if previous_module.write_to_module_with_id == unique_id && previous_module.write_output_variable
          (selected.received_inputs[previous_module.write_output_variable] ||=[]).push(*previous_module.output)
        end
      end

      # pre-calculate any secgen_local/local.rb outputs
      if selected.local_calc_file
        Print.verbose 'Module includes local calculation of output. Processing...'
        # build arguments
        args_string = ''
        selected.received_inputs.each do |input_key, input_values|
          puts input_values.inspect
          input_values.each do |input_element|
            args_string += "'--#{input_key}=#{input_element}' "
          end
        end

        Print.debug "#{selected.local_calc_file} #{args_string}"
        selected.output = JSON.parse(`ruby #{selected.local_calc_file} #{args_string}`.chomp)
        Print.verbose "Output: #{selected.output}"
      end

      # add any modules that the selected module requires
      dependencies = select_required_modules(selected, available_modules, previously_selected_modules + [selected])
    end

    selected_modules = dependencies + [selected]

    Print.std "Module added: #{selected.printable_name}"

    selected_modules
  end

  def check_conflicts_with_list(module_for_possible_exclusion, selected_modules)
    found_conflict = false
    selected_modules.each do |prev_selected|
      if module_for_possible_exclusion.conflicts_with(prev_selected) ||
          prev_selected.conflicts_with(module_for_possible_exclusion)
        Print.verbose "Excluding incompatible module: #{module_for_possible_exclusion.module_path} (conflicts with #{prev_selected.module_path})"
        self.num_actioned_module_conflicts += 1
        found_conflict = true
      end
    end
    found_conflict
  end

  # for a single dependency
  # returns a module that satisfies the requirement from a list of modules provided
  # returns nil when the requirement cannot be satisfied
  def resolve_dependency(required, provided_modules)
    provided_modules.each do |possibly_add|
      if possibly_add.matches_attributes_requirement(required)
        return possibly_add
      end
    end
    # couldn't satisfy requirement!
    return nil
  end

  # returns a list of modules that satisfies all dependencies for the given module
  # returns an empty list if there are no requirements
  def select_required_modules(required_by, available_modules, selected_modules)
    modules_to_add = []
    if required_by.requires.size > 0
      Print.verbose "Resolving dependencies for #{required_by.printable_name}"
    end

    required_by.requires.each do |required|
      Print.verbose "Resolving dependency: #{required.inspect}"
      # checking whether dependency is satisfied by previously selected modules
      existing = resolve_dependency(required, selected_modules)
      if existing != nil
        Print.verbose "Dependency satisfied by previously selected module: #{existing.printable_name}"
      else
        Print.verbose 'Adding required modules...'
        modules_to_add += select_modules('any', required, available_modules, modules_to_add + selected_modules, '', '', '', {})
      end
    end
    modules_to_add
  end

  def validate_windows_base
    windows_vagrant_box = 'modules_bases_windows_2008_r2_64'
    packed_box = 'windows_2008_r2_virtualbox.box'

    Dir.chdir WINDOWS_BASE_PATH
    unless windows_box_in_vagrant? windows_vagrant_box
      Print.info "Packing windows base box: This may take a while ..."
      GemExec.exe('packer', WINDOWS_BASE_PATH, 'build -force windows_2008_r2.json')
      if File.exists? packed_box
        GemExec.exe('vagrant', WINDOWS_BASE_PATH,
                    "box add --name #{windows_vagrant_box} #{packed_box}")
      else
        Print.err 'Error packing windows_2008_r2_virtualbox.box'
        exit
      end
    end
  end

  def windows_box_in_vagrant? (windows_vagrant_box)
    box_in_vagrant = false
    box_list_output = `vagrant box list`
    boxes = box_list_output.split("\n")
    boxes.each do |box_name|
      if /^#{windows_vagrant_box}/.match(box_name)
        box_in_vagrant = true
      end
    end
    box_in_vagrant
  end

  def get_windows_build_modules(available_modules)
    windows_build_modules = []
    available_modules.each do |mod|
      if mod.attributes['module_path'][0] == 'modules/build/windows/chocolatey'
        Print.std "Module added: #{mod.printable_name}"
        windows_build_modules += [mod]
      end
    end
    windows_build_modules
  end
end