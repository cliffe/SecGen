require 'fileutils'
require 'getoptlong'
require 'open3'
require 'pg'
require 'json'

require_relative '../helpers/print.rb'
require_relative '../helpers/constants.rb'

# Globals
@status_enum = {:todo => 'todo', :running => 'running', :success => 'success', :error => 'error', :failed => 'error'}
@prepared_statements = []
@secgen_args = ''
@ranges_in_table = nil

# Displays secgen_batch usage data
def usage
  Print.std "Usage:
   #{$0} <command> [--options]

   COMMANDS:
   add, a: Adds a job to the queue
   start: Starts the service, works through the job queue
   reset: Resets jobs in the table to 'todo' status based on option
   delete: Delete job(s) from the queue table
   list: Lists the current entries in the job queue

   OPTIONS:
   [add]
   --instances [integer n]: Number of instances of the scenario to create with default project naming format
   --instances [prefix,prefix, ...]: Alternatively supply a comma separated list of strings to prefix to project output
   --randomise-ips [integer n ](optional): Randomises the IP range 10.X.X.0, unique for all instances,
                                           requires the number of unique static network tags in the scenario.xml
   ---: Delimiter, anything after this will be passed to secgen.rb as an argument.
   Example: `ruby batch_secgen.rb add --instances here,are,some,prefixes --- -s scenarios/default_scenario.xml run`

   [start]
   --max_threads [integer n] (optional): Maximum number of worker threads, defaults to 1

   [reset]
   --running: Reset all 'running' jobs to 'todo'
   --failed / --error: Reset all failed (i.e. status => 'error') jobs to 'todo'

   [delete]
   --id [integer n]: Delete the entry for a specific Job ID
   --all: Delete all jobs from the queue table

   [list]
   --all (default): List all jobs in the queue table
   --id [integer n] (optional): List the entry for a specific Job ID
   --todo (optional): List jobs with status 'todo'
   --running (optional): List jobs with status 'running'
   --success (optional): List jobs with status 'success'
   --failed / --error (optional): List jobs with status 'error'

   [misc]
   --help, -h: Shows this usage information

"
  exit
end

def misc_opts
  [['--help', '-h', GetoptLong::NO_ARGUMENT]]
end

def get_add_opts
  add_options = misc_opts + [['--instances', '-i', GetoptLong::REQUIRED_ARGUMENT],
                             ['--randomise-ips', GetoptLong::REQUIRED_ARGUMENT]]
  options = parse_opts(GetoptLong.new(*add_options))
  if options.has_key? :instances
    options
  else
    Print.err 'Error: The add command requires an argument.'
    usage
  end
end

def get_start_opts
  start_options = misc_opts + [['--max_threads', GetoptLong::REQUIRED_ARGUMENT]]
  parse_opts(GetoptLong.new(*start_options))
end

def get_list_opts
  list_options = misc_opts + [['--id', GetoptLong::REQUIRED_ARGUMENT],
                              ['--all', GetoptLong::OPTIONAL_ARGUMENT],
                              ['--todo', GetoptLong::NO_ARGUMENT],
                              ['--running', GetoptLong::NO_ARGUMENT],
                              ['--success', GetoptLong::NO_ARGUMENT],
                              ['--failed', '--error', GetoptLong::NO_ARGUMENT]]
  parse_opts(GetoptLong.new(*list_options))
end

def get_reset_opts
  list_options = misc_opts + [['--all', GetoptLong::NO_ARGUMENT],
                              ['--running', GetoptLong::NO_ARGUMENT],
                              ['--failed', '--error', GetoptLong::NO_ARGUMENT]]

  options = parse_opts(GetoptLong.new(*list_options))
  if !options[:running] and !options[:failed] and !options[:all]
    Print.err 'Error: The reset command requires an argument.'
    usage
  else
    options
  end
end

def get_delete_opts
  delete_options = misc_opts + [['--id', GetoptLong::REQUIRED_ARGUMENT],
                                ['--all', GetoptLong::OPTIONAL_ARGUMENT],
                                ['--failed', GetoptLong::OPTIONAL_ARGUMENT]]
  options = parse_opts(GetoptLong.new(*delete_options))
  if !options[:id] and !options[:all] and !options[:failed]
    Print.err 'Error: The delete command requires an argument.'
    usage
  else
    options
  end
end

def parse_opts(opts)
  options = {:instances => '', :max_threads => 3, :id => nil, :all => false}
  opts.each do |opt, arg|
    case opt
      when '--instances'
        options[:instances] = arg
      when '--max_threads'
        options[:max_threads] = arg
      when '--id'
        options[:id] = arg
      when '--randomise-ips'
        options[:random_ips] = arg.to_i
      when '--all'
        options[:all] = true
      when '--todo'
        options[:todo] = true
      when '--running'
        options[:running] = true
      when '--success'
        options[:success] = true
      when '--failed'
        options[:failed] = true
      else
        Print.err 'Invalid argument'
        exit(false)
    end
  end
  options
end

# Command Functions

def add(options)
  db_conn = PG::Connection.open(:dbname => 'batch_secgen')

  # Handle --instances
  instances = options[:instances]
  if (instances.to_i.to_s == instances) and instances.to_i >= 1
    instances.to_i.times do |count|
      instance_args = "--prefix batch_job_#{(count+1).to_s} " + @secgen_args
      instance_args = generate_range_arg(db_conn, options) + instance_args
      insert_row(db_conn, @prepared_statements, count.to_s, instance_args)
    end
  elsif instances.size > 0
    named_prefixes = instances.split(',')
    named_prefixes.each_with_index do |named_prefix, count|
      instance_secgen_args = "--prefix #{named_prefix} " + @secgen_args
      instance_secgen_args = generate_range_arg(db_conn, options) + instance_secgen_args
      insert_row(db_conn, @prepared_statements, count.to_s, instance_secgen_args)
    end
  end
  db_conn.finish
end

def start(options)
  # Start in SecGen's ROOT_DIR
  Dir.chdir ROOT_DIR

  # Create directories
  Dir.mkdir 'log' unless Dir.exists? 'log'
  FileUtils.mkdir_p 'batch/successful' unless Dir.exists? 'batch/successful'
  FileUtils.mkdir_p 'batch/failed' unless Dir.exists? 'batch/failed'

  # Start the service and call secgen.rb
  current_threads = []
  outer_loop_db_conn = PG::Connection.open(:dbname => 'batch_secgen')
  while true
    if (get_jobs(outer_loop_db_conn, @prepared_statements).size > 0) and (current_threads.size < options[:max_threads].to_i)
      current_threads << Thread.new {
        db_conn = PG::Connection.open(:dbname => 'batch_secgen')
        threadwide_statements = []
        current_job = get_jobs(db_conn, threadwide_statements)[0]
        job_id = current_job['id']
        update_status(db_conn, threadwide_statements, job_id, :running)
        secgen_args = current_job['secgen_args']

        # execute secgen
        puts "Running job_id(#{job_id}): secgen.rb #{secgen_args}"
        stdout, stderr, status = Open3.capture3("bundle exec ruby secgen.rb #{secgen_args}")

        # Update job status and back-up paths
        if status.exitstatus == 0
          puts "Job #{job_id} Complete: successful"
          update_status(db_conn, threadwide_statements, job_id, :success)
          log_prefix = ''
          backup_path = 'batch/successful/'
        else
          puts "Job #{job_id} Complete: failed"
          update_status(db_conn, threadwide_statements, job_id, :error)
          log_prefix = 'ERROR_'
          backup_path = 'batch/failed/'
        end

        # Get project data from SecGen output
        project_id = project_path = 'unknown'
        stderr_project_split = stdout.split('Creating project: ')
        if stderr_project_split.size > 1
          project_path = stderr_project_split[1].split('...')[0]
          project_id = project_path.split('projects/')[1]
        else
          project_id = "job_#{job_id}"
          update_status(db_conn, threadwide_statements, job_id, :error)
          Print.err(stderr)
          Print.err("Fatal error on job #{job_id}: SecGen crashed before project creation.")
          Print.err('Check your scenario file.')
        end

        # Log output
        log_name = "#{log_prefix}#{project_id}"
        log_path = "log/#{log_name}"
        log = File.new(log_path, 'w')
        log.write("SecGen project path::: #{project_path}\n\n\n")
        log.write("SecGen arguments::: #{secgen_args}\n\n\n")
        log.write("SecGen output (stdout)::: \n\n\n")
        log.write(stdout)
        log.write("\n\n\nGenerator local output and errors (stderr)::: \n\n\n")
        log.write(stderr)
        log.close

        # Back up project and log file
        FileUtils.cp_r(project_path, backup_path)
        FileUtils.cp(log_path, (backup_path + project_id + '/' + log_name))

        db_conn.finish
      }
      sleep(5)
    else
      current_threads.delete_if { |thread| !thread.alive? }
      sleep(5) # don't use a busy-waiting loop, choose a blocking sleep that frees up CPU
    end
  end

end

def list(options)
  db_conn = PG::Connection.open(:dbname => 'batch_secgen')
  if options[:id]
    items = [select_id(db_conn, @prepared_statements, options[:id])]
  elsif options[:todo]
    items = select_status(db_conn, @prepared_statements, :todo)
  elsif options[:running]
    items = select_status(db_conn, @prepared_statements, :running)
  elsif options[:success]
    items = select_status(db_conn, @prepared_statements, :success)
  elsif options[:failed]
    items = select_status(db_conn, @prepared_statements, :failed)
  else #all
    items = select_all(db_conn)
  end
  items.each do |row|
    Print.info row.to_json
  end

  db_conn.finish
end

# reset jobs in batch to status => 'todo'
def reset(options)
  db_conn = PG::Connection.open(:dbname => 'batch_secgen')
  if options[:all]
    update_all_to_status(db_conn, @prepared_statements, :todo)
  end
  if options[:running]
    update_all_by_status(db_conn, @prepared_statements, :running, :todo)
  end
  if options[:failed]
    update_all_by_status(db_conn, @prepared_statements, :error, :todo)
  end
  db_conn.finish
end

def delete(options)
  db_conn = PG::Connection.open(:dbname => 'batch_secgen')
  if options[:id]
    delete_id(db_conn, @prepared_statements, options[:id])
  elsif options[:failed]
    delete_failed(db_conn)
  elsif options[:all]
    delete_all(db_conn)
  end
  db_conn.finish
end

# Database interactions
def insert_row(db_conn, prepared_statements, statement_id, secgen_args)
  statement = "insert_row_#{statement_id}"
  # Add --shutdown and strip trailing whitespace
  secgen_args = '--shutdown ' + secgen_args.strip
  Print.info "Adding to queue: '#{statement}' '#{secgen_args}' 'todo'"
  unless prepared_statements.include? statement
    db_conn.prepare(statement, 'insert into queue (secgen_args, status) values ($1, $2) returning id')
    prepared_statements << statement
  end
  result = db_conn.exec_prepared(statement, [secgen_args, 'todo'])
  Print.info "id: #{result.first['id']}"
end

def select_all(db_conn)
  db_conn.exec_params('SELECT * FROM queue;')
end

def select_status(db_conn, prepared_statements, status)
  statement = "select_status_#{status}"
  unless prepared_statements.include? statement
    db_conn.prepare(statement, 'SELECT * FROM queue where status = $1;')
    prepared_statements << statement
  end
  db_conn.exec_prepared(statement, [@status_enum[status]])
end

def select_id(db_conn, prepared_statements, id)
  statement = "select_id_#{id}"
  unless prepared_statements.include? statement
    db_conn.prepare(statement, 'SELECT * FROM queue where id = $1;')
    prepared_statements << statement
  end
  db_conn.exec_prepared(statement, [id]).first
end

def update_status(db_conn, prepared_statements, job_id, status)
  statement = "update_status_#{job_id}_#{status}"
  unless prepared_statements.include? statement
    db_conn.prepare(statement, 'UPDATE queue SET status = $1 WHERE id = $2')
    prepared_statements << statement
  end
  db_conn.exec_prepared(statement, [@status_enum[status], job_id])
end

def update_all_by_status(db_conn, prepared_statements, from_status, to_status)
  statement = "mass_update_status_#{from_status}_#{to_status}"
  unless prepared_statements.include? statement
    db_conn.prepare(statement, 'UPDATE queue SET status = $1 WHERE status = $2')
    prepared_statements << statement
  end
  db_conn.exec_prepared(statement, [@status_enum[to_status], @status_enum[from_status]])
end

def update_all_to_status(db_conn, prepared_statements, to_status)
  statement = "mass_update_to_status_#{to_status}"
  unless prepared_statements.include? statement
    db_conn.prepare(statement, 'UPDATE queue SET status = $1')
    prepared_statements << statement
  end
  db_conn.exec_prepared(statement, [@status_enum[to_status]])
end

def delete_failed(db_conn)
  Print.info 'Are you sure you want to DELETE failed jobs from the queue table? [y/N]'
  input = STDIN.gets.chomp
  if input == 'Y' or input == 'y'
    Print.info "'Deleting all jobs with status == 'error' from Queue table"
    db_conn.exec_params("DELETE FROM queue WHERE status = 'error';")
  else
    exit
  end
end

def delete_all(db_conn)
  Print.info 'Are you sure you want to DELETE all jobs from the queue table? [y/N]'
  input = STDIN.gets.chomp
  if input == 'Y' or input == 'y'
    Print.info 'Deleting all jobs from Queue table'
    db_conn.exec_params('DELETE FROM queue;')
  else
    exit
  end
end

def delete_id(db_conn, prepared_statements, id)
  Print.info "Deleting job_id: #{id}"
  statement = "delete_job_id_#{id}"
  unless prepared_statements.include? statement
    db_conn.prepare(statement, 'DELETE FROM queue where id = $1')
    prepared_statements << statement
  end
  db_conn.exec_prepared(statement, [id])
end

def get_jobs(db_conn, prepared_statements)
  select_status(db_conn, prepared_statements, :todo).to_a
end

def secgen_arg_network_ranges(secgen_args)
  ranges_in_arg = []
  split_args = secgen_args.split(' ')
  network_ranges_index = split_args.find_index('--network-ranges')
  if network_ranges_index != nil
    range = split_args[network_ranges_index + 1]
    if range.include?(',')
      range.split(',').each { |split_range| ranges_in_arg << split_range }
    else
      ranges_in_arg << range
    end
  end
  ranges_in_arg
end

def generate_range_arg(db_conn, options)
  range_arg = ''
  if options.has_key? :random_ips

    # Check if there are jobs in the DB containing ips. Assign once so that repeated calls don't get added to the list.
    if @ranges_in_table == nil
      @ranges_in_table = []

      # Exclude IP ranges previously selected, stored in the table
      table_entries = select_all(db_conn)
      table_entries.each { |job|
        @ranges_in_table += secgen_arg_network_ranges(job['secgen_args'])
      }
    end

    generated_network_ranges = []
    scenario_networks_qty = options[:random_ips]
    scenario_networks_qty.times {
      range = generate_range
      # Check for uniqueness
      while @ranges_in_table.include?(range)
        range = generate_range
      end
      @ranges_in_table << range
      generated_network_ranges << range
    }
    random_ip_string = generated_network_ranges.join(',')
    range_arg = "--network-ranges #{random_ip_string} "
  end
  range_arg
end

def generate_range
  "10.#{rand(255)}.#{rand(255)}.0"
end

Print.std '~'*47
Print.std 'SecGen Batch - Batch VM Generation Service'
Print.std '~'*47

# Capture SecGen options
delimiter_index = ARGV.find_index('---')
if delimiter_index
  ARGV[delimiter_index+1..ARGV.length].each { |secgen_arg|
    @secgen_args += secgen_arg + ' '
  }
  # Reassign ARGV to values before delimiter (and suppress constant reassignment warning)
  original_verbose, $VERBOSE = $VERBOSE, nil
  ARGV = ARGV[0..delimiter_index - 1]
  $VERBOSE = original_verbose
end

# Run command
case ARGV[0]
  when 'add'
    add(get_add_opts)
  when 'start'
    start(get_start_opts)
  when 'list'
    list(get_list_opts)
  when 'reset'
    reset(get_reset_opts)
  when 'delete'
    delete(get_delete_opts)
  else
    usage
end
