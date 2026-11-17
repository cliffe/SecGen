require 'json'
require 'fileutils'
require 'time'
require 'open3'
require 'rexml/document'
require_relative 'constants.rb'
require_relative 'print.rb'

# Runs a project's secgen_tests and keeps their results per the results
# contract (README-Testing.md):
#
#   test_results/<project-id>/
#     summary.json  scenario.xml  build.log
#     <system>/<module>.json  <module>.log  evidence/<module>/*.txt
#
# Each test writes projects/<id>/test_results/<system>/<module>.json itself
# (PostProvisionTest); this runs them, keeps their output as <module>.log, and
# copies everything out of the project with the Proxmox password masked.
module TestResults
  RESULTS_DIR = "#{OUTPUT_DIR}/test_results".freeze
  STATUS_ORDER = %w[PASS SKIP FAIL].freeze # worst last
  EXIT_CODES = { 'PASS' => 0, 'FAIL' => 1, 'SKIP' => 2 }.freeze
  MASK = '********'.freeze
  # secrets secgen.rb takes from --read-options and passes on via the environment
  SECRET_ENV_VARS = %w[SECGEN_PROXMOX_PASS SECGEN_LLM_API_KEY].freeze

  module_function

  def project_id(project_dir)
    File.basename(File.expand_path(project_dir))
  end

  def results_dir(project_dir)
    "#{RESULTS_DIR}/#{project_id(project_dir)}"
  end

  def test_scripts(project_dir)
    Dir.glob("#{project_dir}/puppet/*/modules/*/secgen_test/*.rb").sort
  end

  # Runs every secgen_test in the project, SECGEN_TEST_JOBS (default 4) at a
  # time, each with a timeout, and returns [{system, module, status,
  # tier_reached, exit_code}] in script order. Each test is its own process
  # talking to the guest agent, so most of the time is spent waiting on the
  # Proxmox API (~3s a call): running them side by side cuts the wall time.
  # Scripts in the same module dir share its JSON/log, so they run in turn.
  # A test that dies without writing its JSON is recorded as SKIP (or FAIL if
  # it exited 1).
  def run_tests(project_dir, timeout: (ENV['SECGEN_TEST_TIMEOUT'] || 900).to_i,
                jobs: (ENV['SECGEN_TEST_JOBS'] || 4).to_i)
    scripts = test_scripts(project_dir)
    groups = scripts.each_with_index.group_by { |script, _| script.split('/')[-5, 3].join('/') }.values
    jobs = [[jobs, 1].max, groups.size].min
    return [] if scripts.empty?

    Print.info "Running #{scripts.size} test(s), up to #{jobs} at a time"
    started = Time.now
    queue = Queue.new
    groups.each { |group| queue << group }
    results = Array.new(scripts.size)
    print_lock = Mutex.new
    workers = Array.new(jobs) do
      Thread.new do
        loop do
          group = begin
            queue.pop(true)
          rescue ThreadError
            break
          end
          group.each { |script, i| results[i] = run_test(project_dir, script, timeout, print_lock) }
        end
      end
    end
    workers.each(&:join)
    Print.info "#{scripts.size} test(s) finished in #{(Time.now - started).round}s"
    results
  end

  # Runs one test script; prints its output in one block when it finishes.
  def run_test(project_dir, script, timeout, print_lock)
    system = script.split('/')[-5]
    mod = script.split('/')[-3]
    out_dir = "#{project_dir}/test_results/#{system}"
    FileUtils.mkdir_p(out_dir)
    json_path = "#{out_dir}/#{mod}.json"
    log_path = "#{out_dir}/#{mod}.log"
    FileUtils.rm_f(json_path)

    print_lock.synchronize { Print.std "Testing #{system}/#{mod} (#{File.basename(script)})" }
    started = Time.now
    exit_code = begin
      run_with_timeout(['bundle', 'exec', 'ruby', script], log_path, timeout)
    rescue StandardError => e
      File.write(log_path, "Could not run test: #{e.class}: #{e.message}\n", mode: 'a')
      nil
    end

    unless File.exist?(json_path)
      status = exit_code == 1 ? 'FAIL' : 'SKIP'
      detail = exit_code.nil? ? "timed out after #{timeout}s or could not run" : "exited #{exit_code} without writing results"
      File.write(json_path, JSON.pretty_generate(
        module: mod, module_path: nil, system: system, backend: nil,
        started_at: started.iso8601, duration_s: (Time.now - started).round(1),
        status: status, tier_reached: 0,
        results: [{ tier: 1, name: 'test produced no results', status: status,
                    detail: "#{detail}; see #{mod}.log" }]) + "\n")
    end
    result = JSON.parse(File.read(json_path))
    status = result['status']
    # A FAIL exit with a non-FAIL JSON, or a crash after writing, is a FAIL.
    status = 'FAIL' if exit_code == 1 && status != 'FAIL'
    log = File.exist?(log_path) ? File.read(log_path) : ''
    print_lock.synchronize do
      Print.std "#{system}/#{mod} (#{(Time.now - started).round}s):"
      log.each_line { |line| Print.std "  #{line.chomp}" }
      print_status(system, mod, status)
    end
    { 'system' => system, 'module' => mod, 'status' => status,
      'tier_reached' => result['tier_reached'], 'exit_code' => exit_code }
  end

  # Runs argv with stdout+stderr to log_path; returns its exit code, or nil if
  # it was killed for running longer than timeout seconds.
  def run_with_timeout(argv, log_path, timeout)
    pid = Process.spawn(*argv, out: log_path, err: [:child, :out], pgroup: true)
    deadline = Time.now + timeout
    loop do
      done, status = Process.wait2(pid, Process::WNOHANG)
      return status.exitstatus if done
      if Time.now > deadline
        Process.kill('-KILL', pid) rescue nil
        Process.wait(pid) rescue nil
        File.write(log_path, "\nKilled: test ran longer than #{timeout}s\n", mode: 'a')
        return nil
      end
      sleep 1
    end
  end

  def print_status(system, mod, status)
    msg = "#{status}: #{system}/#{mod}"
    case status
    when 'PASS' then Print.info msg
    when 'FAIL' then Print.err msg
    else Print.warn msg
    end
  end

  # Worst of the given statuses (FAIL > SKIP > PASS); PASS if none.
  def worst(statuses)
    statuses.max_by { |s| STATUS_ORDER.index(s) || STATUS_ORDER.size } || 'PASS'
  end

  # Copies src to dst with the Proxmox password replaced by MASK (literal, not
  # a regex; the password never goes near a command line). Returns the number
  # of replacements.
  def copy_masked(src, dst)
    FileUtils.mkdir_p(File.dirname(dst))
    data = File.binread(src)
    count = 0
    SECRET_ENV_VARS.each do |var|
      secret = ENV[var].to_s.b
      next if secret.empty?
      found = data.scan(secret).size
      data = data.gsub(secret, MASK) if found > 0
      count += found
    end
    File.binwrite(dst, data)
    count
  end

  # Copies the project's test results and resolved scenario into
  # test_results/<project-id>/ and writes summary.json. build: {status,
  # attempts, log}. Returns the summary hash.
  def write_report(project_dir, source_scenario:, build:, started_at:, test_runs: [])
    out = results_dir(project_dir)
    FileUtils.mkdir_p(out)
    masked = 0

    scenario_xml = "#{project_dir}/scenario.xml"
    masked += copy_masked(scenario_xml, "#{out}/scenario.xml") if File.exist?(scenario_xml)

    # Only the test outputs: json, logs, evidence. Never the Vagrantfile,
    # systems, datastores, flags/hints or test_context.json.
    project_results = "#{project_dir}/test_results"
    Dir.glob("#{project_results}/**/*").select { |f| File.file?(f) }.each do |f|
      masked += copy_masked(f, "#{out}/#{f.sub("#{project_results}/", '')}")
    end

    runs = test_runs.group_by { |r| r['system'] }
    systems = system_names(project_dir).map do |system|
      modules = Dir.glob("#{out}/#{system}/*.json").sort.map do |json|
        result = JSON.parse(File.read(json)) rescue {}
        mod = File.basename(json, '.json')
        run = (runs[system] || []).find { |r| r['module'] == mod } || {}
        { module: mod, status: run['status'] || result['status'], tier_reached: result['tier_reached'],
          result: "#{system}/#{mod}.json" }
      end
      { system: system, base: base_module(project_dir, system), vmid: vmid(project_dir, system), modules: modules }
    end

    module_statuses = systems.flat_map { |s| s[:modules].map { |m| m[:status] } }
    counts = { 'PASS' => 0, 'FAIL' => 0, 'SKIP' => 0 }
    module_statuses.each { |s| counts[s] = counts.fetch(s, 0) + 1 }
    status = build[:status] == 'success' ? worst(module_statuses) : 'FAIL'

    summary = {
      project: project_id(project_dir),
      source_scenario: relative(source_scenario),
      secgen_commit: git('rev-parse', 'HEAD'),
      secgen_branch: git('rev-parse', '--abbrev-ref', 'HEAD'),
      started_at: started_at.iso8601,
      finished_at: Time.now.iso8601,
      build: build,
      status: status,
      counts: counts,
      masked_secrets: masked,
      systems: systems
    }
    File.write("#{out}/summary.json", JSON.pretty_generate(summary) + "\n")
    Print.warn "Masked #{masked} occurrence(s) of the Proxmox password in copied results: fix the source." if masked > 0
    Print.info "Test results: #{relative(out)} (#{status}; #{counts.map { |k, v| "#{v} #{k}" }.join(', ')})"
    summary
  end

  # After a PASS, records whether the VMs were rolled back to their pre-test
  # snapshot (failed: names of VMs that weren't) and rewrites summary.json. A
  # VM left with the tests' traces is a FAIL: surviving VMs are taken as clean.
  def record_revert(project_dir, summary, failed)
    summary = summary.merge(revert: { status: failed.empty? ? 'success' : 'failed', failed_vms: failed })
    unless failed.empty?
      summary[:status] = 'FAIL'
      Print.err "Could not roll back to the pre-test snapshot: #{failed.join(', ')}"
    end
    File.write("#{results_dir(project_dir)}/summary.json", JSON.pretty_generate(summary) + "\n")
    summary
  end

  def system_names(project_dir)
    Dir.glob("#{project_dir}/puppet/*").select { |d| File.directory?(d) }.map { |d| File.basename(d) }.sort
  end

  # Base module path of a system, from the project's resolved scenario.xml.
  def base_module(project_dir, system)
    doc = REXML::Document.new(File.read("#{project_dir}/scenario.xml"))
    doc.root.each_element('system') do |s|
      next unless s.elements['system_name']&.text.to_s.strip == system
      base = s.elements['base']
      return base && base.attributes['module_path']
    end
    nil
  rescue StandardError
    nil
  end

  # "node/vmid" written by vagrant-proxmox, or nil.
  def vmid(project_dir, system)
    path = "#{project_dir}/.vagrant/machines/#{system}/proxmox/id"
    File.exist?(path) ? File.read(path).strip : nil
  end

  def relative(path)
    return nil if path.nil?
    full = File.expand_path(path)
    full.start_with?("#{ROOT_DIR}/") ? full.sub("#{ROOT_DIR}/", '') : full
  end

  def git(*args)
    out, status = Open3.capture2('git', '-C', ROOT_DIR, *args)
    status.success? ? out.strip : nil
  rescue StandardError
    nil
  end
end
