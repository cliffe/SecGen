require 'json'
require 'base64'
require 'duplicate'

class System

  attr_accessor :name
  attr_accessor :attributes # (basebox selection)
  attr_accessor :module_selectors # (filters)
  attr_accessor :module_selections # (after resolution)
  attr_accessor :num_actioned_module_conflicts

  # Attributes for resetting retry loop
  attr_accessor :available_mods #(command line options hash)
  attr_accessor :original_datastores #(command line options hash)
  attr_accessor :original_module_selectors #(command line options hash)
  attr_accessor :original_available_modules #(command line options hash)

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
  # @param [Object] options command line options hash
  # @return [Object] the list of selected modules
  def resolve_module_selection(available_modules, options)
    retry_count = 0

    # duplicate original data and parameters for retries
    self.available_mods = duplicate(available_modules)
    self.original_datastores = duplicate($datastore)
    self.original_module_selectors = duplicate(module_selectors)
    self.original_available_modules = duplicate(available_mods)

    begin
      selected_modules = []
      self.num_actioned_module_conflicts = 0
      replace_datastore_ips(options)

      # for each module specified in the scenario
      module_selectors.each do |module_filter|
        selected_modules += select_modules(module_filter.module_type, module_filter.attributes, available_mods, selected_modules, module_filter.unique_id, module_filter.write_output_variable, module_filter.write_to_module_with_id, module_filter.received_inputs, module_filter.default_inputs_literals, module_filter.write_to_datastore, module_filter.received_datastores, module_filter.write_module_path_to_datastore)
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
        # reset module_filters recieved inputs
        # We need a way to distinguish between the received inputs from values vs from generators
        self.module_selectors = duplicate(self.original_module_selectors)
        self.available_mods = duplicate(self.original_available_modules)
        # reset globals
        $datastore = duplicate(self.original_datastores)
        $datastore_iterators = {}
        retry
      else
        Print.err "Tried re-randomising #{RETRIES_LIMIT} times. Still no joy."
        Print.err 'Please review the scenario -- something is wrong.'
        exit
      end
    end
  end

  def replace_datastore_ips(options)
    begin
      if options[:ip_ranges] and $datastore['IP_addresses'] and !$datastore['replaced_ranges']
        unused_opts_ranges = options[:ip_ranges].clone
        option_range_map = {} # k = ds_range, v = opts_range
        new_ip_addresses = []

        # Iterate over the DS IPs
        $datastore['IP_addresses'].each do |ds_ip_address|
          # Split the IP into ['X.X.X', 'Y']
          split_ip = ds_ip_address.split('.')
          ds_ip_array = [split_ip[0..2].join('.'), split_ip[3]]
          ds_range = ds_ip_array[0] + '.0'
          # Check if we have encountered first 3 octets before i.e. look in option_range_map for key(ds_range)
          if option_range_map.has_key? ds_range
            # if we have, grab that value (opts_range)
            opts_range = option_range_map[ds_range]
            # replace first 3 in ds_ip with first 3 in opts_range
            split_opts_range = opts_range.split('.')
            split_opts_range[3] = ds_ip_array[1]
            new_ds_ip = split_opts_range.join('.')
            # save in $datastore['IP_addresses']
            new_ip_addresses << new_ds_ip
          else #(if we haven't seen the first 3 octets before)
            # grab the first range that we haven't used yet from unused_opts_ranges with .shift (also removes the range)
            opts_range = unused_opts_ranges.shift
            # store the range mapping in option_range_map (ds_range => opts_range)
            option_range_map[ds_range] = opts_range
            # split the opts_range and replace last octet with last octet of ds_ip_address
            split_opts_range = opts_range.split('.')
            split_opts_range[3] = ds_ip_array[1]
            new_ds_ip = split_opts_range.join('.')
            # save in $datastore['IP_addresses']
            new_ip_addresses << new_ds_ip
          end
        end
        $datastore['IP_addresses'] = new_ip_addresses
        $datastore['replaced_ranges'] = true
      end
    rescue NoMethodError
      required_ranges = []
      $datastore['IP_addresses'].each { |ip_address|
        split_range = ip_address.split('.')
        split_range[3] = 0
        required_ranges << split_range.join('.')
      }
      required_ranges.uniq!
      Print.err("Fatal: Not enough ranges were provided with --network-ranges. Provided: #{options[:ip_ranges].size} Required: #{required_ranges.uniq.size}")
      exit
    end
  end

  # returns a list containing a module (plus any default input modules and dependencies recursively) of the module type with the required attributes
  # modules are selected from the list of available modules and will be checked against previously selected modules for conflicts
  # raises an exception when unable to resolve and the retry limit has not been reached
  def select_modules(module_type, required_attributes, available_modules, previously_selected_modules, unique_id, write_outputs_to, write_to_module_with_id, received_inputs, default_inputs_literals, write_to_datastore, received_datastores, write_module_path_to_datastore)
    default_modules_to_add = []

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
    # select based on selected type, access, cve...
    search_list.delete_if{|module_for_possible_exclusion|
      !module_for_possible_exclusion.matches_attributes_requirement(required_attributes)
    }
    Print.verbose "Filtered to modules matching: #{required_attributes.inspect} ~= (n=#{search_list.size})"

    # remove non-options due to conflicts
    search_list.delete_if{|module_for_possible_exclusion|
      check_conflicts_with_list(module_for_possible_exclusion, previously_selected_modules)
    }

    # check if modules need to be unique
    # write_module_path_to_datastore
    if write_module_path_to_datastore != nil && $datastore[write_module_path_to_datastore] != nil
      search_list.delete_if{|module_for_possible_exclusion|
        ($datastore[write_module_path_to_datastore] ||=[]).include? module_for_possible_exclusion.module_path
      }
      Print.verbose "Filtering to remove non-unique #{$datastore[write_module_path_to_datastore]} ~= (n=#{search_list.size})"
    end


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
      selected.write_to_datastore = write_to_datastore
      selected.unique_id = unique_id
      selected.received_inputs = received_inputs
      selected.received_datastores = received_datastores
      selected.write_module_path_to_datastore = write_module_path_to_datastore
      selected.default_inputs_literals = selected.default_inputs_literals.merge(default_inputs_literals)

      # add module path to write_module_path_to_datastore
      if selected.write_module_path_to_datastore != nil && selected.write_module_path_to_datastore != ''
        Print.verbose "Adding module_path to datastore (#{selected.write_module_path_to_datastore}) to ensure same module not selected multiple times"
        ($datastore[selected.write_module_path_to_datastore]||=[]).push selected.module_path

      end

      # feed in input from any received datastores
      if selected.received_datastores != {} and $datastore != {}
        Print.verbose "Receiving datastores: #{selected.received_datastores}"
        selected.received_datastores.each do |input_into, datastore_list|
          datastore_list.each do |datastore_variablename_and_access_type|
            datastore_access = datastore_variablename_and_access_type['access']
            datastore_variablename = datastore_variablename_and_access_type['variablename']
            datastore_retrieved = []
            begin
              if datastore_access == 'first'
                datastore_retrieved = [$datastore[datastore_variablename].first]
              elsif datastore_access == 'next'
                last_accessed = $datastore_iterators[datastore_variablename]
                # first use? start at beginning
                if last_accessed == nil
                  index_to_access = 0
                else
                  index_to_access = last_accessed + 1
                end
                $datastore_iterators[datastore_variablename] = index_to_access
                datastore_retrieved = [$datastore[datastore_variablename][index_to_access]]
              elsif datastore_access == 'previous'
                last_accessed = $datastore_iterators[datastore_variablename]
                # first use? start at end
                if last_accessed == nil
                  index_to_access = $datastore[datastore_variablename].size - 1
                else
                  index_to_access = last_accessed - 1
                end
                $datastore_iterators[datastore_variablename] = index_to_access
                datastore_retrieved = [$datastore[datastore_variablename][index_to_access]]
              elsif datastore_access.to_s == datastore_access.to_i.to_s
                # Test for a valid element key (integer)
                index_to_access = datastore_access.to_i
                $datastore_iterators[datastore_variablename] = index_to_access
                datastore_retrieved = [$datastore[datastore_variablename][index_to_access]]
              elsif datastore_access == "all"
                datastore_retrieved = $datastore[datastore_variablename]
              else
                Print.err "Error: invalid access value (#{datastore_access})"
                raise 'failed'
              end
            rescue NoMethodError, SyntaxError => err
              Print.err "Error accessing element (#{datastore_access}) from datastore (#{datastore_variablename}): #{err}"
              raise 'failed'
            end
            if datastore_retrieved && datastore_retrieved != [nil]
              # separate out the data if there's a 'access_json' call
              datastore_access_json = datastore_variablename_and_access_type['access_json']

              if datastore_access_json.size > 0
                # use first element when selecting access_json unless access="" is specified
                if datastore_access == 'all'
                  datastore_access = 0
                  Print.verbose "No element specified, e.g. access=\"0\", for access_json=\"#{datastore_access_json}\": using (0)"
                end

                # parse the datastore
                parsed_datastore_element = JSON.parse(datastore_retrieved.first)

                # Sanitise with whitelist of used characters: ' [ ]
                access_json = datastore_access_json.gsub(/[^A-Za-z0-9\[\]'_]/, '')

                # get data from access_json string
                begin
                  json_accessed_data = eval("parsed_datastore_element#{access_json}")
                rescue NoMethodError, SyntaxError => err
                  Print.err "Error fetching access_json (#{access_json}) from datastore (#{datastore_variablename}): #{err}"
                  raise 'failed'
                end
                # convert hashes back to json
                if json_accessed_data.is_a? Hash
                  datastore_retrieved = json_accessed_data.to_json
                elsif json_accessed_data.is_a? Array
                  datastore_retrieved = []
                  json_accessed_data.each do |data_element|
                    if data_element.is_a? Hash
                      data_element = data_element.to_json
                    end
                    datastore_retrieved << data_element
                  end
                else
                  datastore_retrieved = json_accessed_data
                end
              end
              (received_inputs[input_into] ||=[]).push(*datastore_retrieved)
              Print.verbose "Adding (#{datastore_access}) #{datastore_variablename} to #{input_into}: #{datastore_retrieved}"
            else
              Print.err "Error: can't add no data. Feeding #{datastore_retrieved} into #{input_into}"
              Print.err "Check the scenario, not enough data is generated for this datastore (#{datastore_variablename}) to access this index (#{datastore_access})"
              raise 'failed'
            end
          end
        end
      end

      # if no input received from the scenario, apply default input values/modules
      default_modules_to_add += select_default_modules(selected, available_modules, previously_selected_modules + [selected])

      # feed in the input from any previous module's output
      (previously_selected_modules + default_modules_to_add).each do |previous_module|
        # if previous_module.write_to_module_with_id == unique_id && previous_module.write_output_variable && !variables_received_from_scenario.include?(previous_module.write_output_variable)
        if previous_module.write_to_module_with_id == selected.unique_id && previous_module.write_output_variable
          (selected.received_inputs[previous_module.write_output_variable] ||=[]).push(*previous_module.output)
        end
      end

      # pre-calculate any secgen_local/local.rb outputs
      if selected.local_calc_file
        Print.verbose 'Module includes local calculation of output. Processing...'
        # build arguments
        args_string = "--b64 " # Sets the flag for decoding base64
        selected.received_inputs.each do |input_key, input_values|
          puts input_values.inspect
          input_values.each do |input_element|
            if input_key == ''
              Print.warn "Warning: output values not directed to module input"
            else
              args_string += "--#{input_key}=#{Base64.strict_encode64(input_element)} "
            end
          end
        end
        # execute calculation script and format output to an array of Base64 strings
        Print.verbose "Running: ruby #{selected.local_calc_file} #{args_string[0..200]} ..."
        command = "bundle exec ruby #{selected.local_calc_file}"
        stdout, stderr, status = Open3.capture3(command, :stdin_data => args_string)
        puts stderr
        outputs = stdout.chomp

        unless status
          Print.err "Module failed to run (#{command})"
          # TODO: this works, but subsequent attempts at resolving the scenario always fail ("Error can't add no data...")
          raise 'failed'
        end
        output_array = outputs.split("\n")
        selected.output = output_array.map { |o| (Base64.strict_decode64 o).force_encoding('UTF-8') }
      end

      # store the output of the module into a datastore, if specified
      if selected.write_to_datastore && selected.write_to_datastore.size != 0
        ($datastore[selected.write_to_datastore] ||=[]).push(*selected.output)
        Print.verbose "Storing into datastore: #{selected.write_to_datastore} = #{$datastore[selected.write_to_datastore].to_s}"
      end

      # add any modules that the selected module requires
      dependencies = select_required_modules(selected, available_modules, previously_selected_modules + default_modules_to_add + [selected])
    end

    selected_modules = dependencies + default_modules_to_add + [selected]

    Print.std "Module added: #{selected.printable_name}"

    selected_modules
  end

  def select_default_modules(selected, available_modules, previously_selected_modules)
    default_modules_to_add = []

    # detect incoming input from any previous module's output, and record the keys that will be written to
    receives_module_input_into = []
    (previously_selected_modules + default_modules_to_add).each do |previous_module|
      # TODO: track down why we sometimes get an empty "" in previous_module.write_output_variable
      if previous_module.write_to_module_with_id == selected.unique_id && previous_module.write_output_variable && previous_module.write_output_variable != ''
        receives_module_input_into.push previous_module.write_output_variable
      end
    end

    # identify which keys/variables are set via default values (to consider use of defaults)
    default_keys = selected.default_inputs_literals.keys | selected.default_inputs_selectors.keys | receives_module_input_into

    # check whether each defaults should be used
    # for each variable with a default
    default_keys.each do |default_key|
      # if there are no inputs generated by the scenario
      unless selected.received_inputs.has_key? default_key or receives_module_input_into.include? default_key
        Print.verbose "Using defaults for #{default_key}"
        # apply literal values
        if selected.default_inputs_literals.has_key? default_key
          Print.verbose "Using default literal input #{selected.default_inputs_literals[default_key]}"
          (selected.received_inputs[default_key] ||=[]).concat selected.default_inputs_literals[default_key]
        end

        # apply modules
        if selected.default_inputs_selectors.has_key? default_key
          Print.verbose "Using default module input #{selected.default_inputs_selectors[default_key].inspect}"

          default_module_selectors_to_add = selected.default_inputs_selectors[default_key]

          default_module_selectors_to_add.each do |module_to_add|
            # calculate new names for these module instances...
            def_write_to = module_to_add.write_to_module_with_id
            def_unique_id = module_to_add.unique_id
            # write to this module?
            if /^.*defaultinput$/ =~ def_write_to
              def_write_to = selected.unique_id
            end
            # nested default?
            if /^.*defaultinput/ =~ def_write_to
              def_write_to = def_write_to.gsub(/^.*defaultinput/, selected.unique_id)
            end
            if /^.*defaultinput/ =~ def_unique_id
              def_unique_id = def_unique_id.gsub(/^.*defaultinput/, selected.unique_id)
            end

            default_modules_to_add.concat select_modules(module_to_add.module_type, module_to_add.attributes, available_modules, previously_selected_modules + default_modules_to_add, def_unique_id, module_to_add.write_output_variable, def_write_to, module_to_add.received_inputs, module_to_add.default_inputs_literals, module_to_add.write_to_datastore, module_to_add.received_datastores, module_to_add.write_module_path_to_datastore)
          end
        end
      else
        Print.verbose "Scenario includes input for #{default_key} (not using default values)"
      end
    end
    default_modules_to_add
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
        modules_to_add += select_modules('any', required, available_modules, modules_to_add + selected_modules, '', '', '', {}, {}, {}, {}, '')
      end
    end
    modules_to_add
  end

end
