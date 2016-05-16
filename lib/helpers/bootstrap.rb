require 'fileutils'
class Bootstrap

  # Bootstrap the application by creating or moving all relevant puppet files
  def bootstrap
    puts 'Bootstrapping application..'
    #if mount does not exist create the directory structure
    if !Dir.exists?("#{ROOT_DIR}/mount")
      create_directory_structure
      move_vulnerability_puppet_files
      move_secure_service_puppet_files
      move_build_puppet_files
    else #if mount does exist, purge the puppet directory and copy the files
      purge_puppet_files
      create_directory_structure
      move_secure_service_puppet_files
      move_vulnerability_puppet_files
      move_build_puppet_files
    end
    puts 'Application Bootstrapped'
  end

  private

  # Create directory structure for puppet files
  # Structure /mount/puppet/module and /mount/puppet/manifest
  def create_directory_structure
    print 'Mount directory not present, creating..'
    Dir.mkdir("#{ROOT_DIR}/mount")
    print 'Creating Puppet directory..'
    Dir.mkdir("#{ROOT_DIR}/mount/puppet")
    print 'Creating Puppet module directory..'
    Dir.mkdir("#{ROOT_DIR}/mount/puppet/module")
    print 'Creating Puppet manifest directory..'
    Dir.mkdir("#{ROOT_DIR}/mount/puppet/manifest")
    puts ' Complete'
  end

  # Copy all puppet files from /modules/vulnerabilities/ to /mount/puppet/module and /mount/puppet/module
  def move_vulnerability_puppet_files
    puts 'Moving vulnerability manifests'
    Dir.glob("#{ROOT_DIR}/modules/vulnerabilities/*/*/*/*.pp").each do |puppet_file|
      puts "Moving #{puppet_file} to mount/puppet/manifest/"
      FileUtils.copy(puppet_file, "#{ROOT_DIR}/mount/puppet/manifest/")
    end

    puts 'Moving vulnerability modules'
    Dir.glob("#{ROOT_DIR}/modules/vulnerabilities/*/*/*/*/").each do |puppet_module_directory|
      module_path = "#{ROOT_DIR}/mount/puppet/module/"
      puts "Moving #{puppet_module_directory} to #{module_path}"
      FileUtils.cp_r(puppet_module_directory, module_path)
    end
  end

  # Copy all puppet files from /modules/services to /mount/puppet/manifest and /mount/puppet/module
  def move_secure_service_puppet_files
    puts 'Moving Service manifests'
    Dir.glob("#{ROOT_DIR}/modules/services/*/*/*/*.pp").each do |puppet_file|
      puts "Moving #{puppet_file} to mount/puppet/manifest/"
      FileUtils.copy(puppet_file, "#{ROOT_DIR}/mount/puppet/manifest/")
    end

    puts 'Moving Service modules'
    Dir.glob("#{ROOT_DIR}/modules/services/*/*/*/module/**").each do |puppet_module_directory|

      module_path = "#{ROOT_DIR}/mount/puppet/module/"
      puts "Moving #{puppet_module_directory} to #{module_path}"
      FileUtils.cp_r(puppet_module_directory, module_path)


      puts 'Moving vulnerability templates'
    end
  end

  # Move dependency modules, build manifests and build modules
  def move_build_puppet_files

    puts 'Moving Dependency modules'
    Dir.glob("#{ROOT_DIR}/modules/dependencies/**").each do |puppet_module_directory|

        module_path = "#{ROOT_DIR}/mount/puppet/module/"
        puts "Moving #{puppet_module_directory} to #{module_path}"
        FileUtils.cp_r(puppet_module_directory, module_path)
      end

    puts 'Moving build manifests'

    Dir.glob("#{ROOT_DIR}/modules/build/*/*/*.pp").each do |puppet_file|
      puts "Moving #{puppet_file} to mount/puppet/manifest/"
      FileUtils.copy(puppet_file, "#{ROOT_DIR}/mount/puppet/manifest/")
    end

    puts 'Moving build modules'

    Dir.glob("#{ROOT_DIR}/modules/build/*/*/module/**").each do |puppet_module_directory|

      module_path = "#{ROOT_DIR}/mount/puppet/module/"
      puts "Moving #{puppet_module_directory} to #{module_path}"
      FileUtils.cp_r(puppet_module_directory, module_path)
    end


  end

  # Purge all puppet files from mount directory
  def purge_puppet_files
    FileUtils.rm_rf("#{ROOT_DIR}/mount")
  end
end