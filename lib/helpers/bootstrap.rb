class Bootstrap

  def bootstrap
    puts 'Bootstrapping application..'
    #if mount doesnt exist create the directory structure
    if !Dir.exists?("#{ROOT_DIR}/mount")
      create_directory_structure
      move_vulnerability_puppet_files
      move_secure_service_puppet_files
    else #if mount does exist, purge the puppet directory and copy the files
      purge_puppet_files
      move_secure_service_puppet_files
      move_vulnerability_puppet_files
    end
    puts 'Application Bootstrapped'
  end

  private

  def create_directory_structure
    print 'Mount directory not present, creating..'
    Dir.mkdir("#{ROOT_DIR}/mount")
    puts ' Complete'
    print 'Creating Puppet directory..'
    Dir.mkdir("#{ROOT_DIR}/mount/puppet")
    puts ' Complete'
  end

  def move_vulnerability_puppet_files
    puts 'Moving vulnerabilities'
    Dir.glob("#{ROOT_DIR}/modules/vulnerabilities/**/**/puppet/**/*.pp").each do |puppet_file|
      puts "Moving #{puppet_file} to mount/puppet."
      FileUtils.copy(puppet_file, "#{ROOT_DIR}/mount/puppet")
    end
  end

  def move_secure_service_puppet_files
    puts 'Moving secure services'
    Dir.glob("#{ROOT_DIR}/modules/services/**/**/puppet/**/*.pp").each do |puppet_file|
      puts "Moving #{puppet_file} to mount/puppet."
      FileUtils.copy(puppet_file, "#{ROOT_DIR}/mount/puppet")
    end
  end

  def purge_puppet_files
    puts 'Purging puppets directory.'
    Dir.glob("#{ROOT_DIR}/mount/puppet/*.pp").each do |puppet_file|
    File.delete(puppet_file)
    end
  end
end