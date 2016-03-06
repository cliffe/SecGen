require 'fileutils'
class Bootstrap

  def bootstrap
    puts 'Bootstrapping application..'
    #if mount doesnt exist create the directory structure
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

  def move_vulnerability_puppet_files
    puts 'Moving vulnerability manifests'
    Dir.glob("#{ROOT_DIR}/modules/vulnerabilities/**/**/**/*.pp").each do |puppet_file|
      puts "Moving #{puppet_file} to mount/puppet/manifest/"
      FileUtils.copy(puppet_file, "#{ROOT_DIR}/mount/puppet/manifest/")
    end

    puts 'Moving vulnerability modules'
    Dir.glob("#{ROOT_DIR}/modules/vulnerabilities/**/**/**/module/**").each do |puppet_module_directory|
      root_directory_length = ROOT_DIR.split('/').count
      module_name = puppet_module_directory.split('/')[root_directory_length + 4]
      module_path = "#{ROOT_DIR}/mount/puppet/module/#{module_name}"

      if(Dir.exists?(module_path))
        puts "Moving #{puppet_module_directory} to #{module_path}"
        FileUtils.cp_r(puppet_module_directory, module_path)
      else
        Dir.mkdir("#{ROOT_DIR}/mount/puppet/module/#{module_name}")
        puts "Moving #{puppet_module_directory} to #{module_path}"
        FileUtils.cp_r(puppet_module_directory, module_path)
      end

      puts 'Moving vulnerability templates'

    end
  end

  def move_secure_service_puppet_files
    puts 'Moving secure service puppet files'
    Dir.glob("#{ROOT_DIR}/modules/services/**/**/puppet/module/*.pp").each do |puppet_file|
      puts "Moving #{puppet_file} to mount/puppet/module"
      FileUtils.copy(puppet_file, "#{ROOT_DIR}/mount/puppet/module")
    end
    Dir.glob("#{ROOT_DIR}/modules/services/**/**/puppet/manifest/*.pp").each do |puppet_file|
      puts "Moving #{puppet_file} to mount/puppet/manifest."
      FileUtils.copy(puppet_file, "#{ROOT_DIR}/mount/puppet/manifest")
    end
  end

  def move_build_puppet_files

    puts 'Moving build puppet module files'
    Dir.glob("#{ROOT_DIR}/modules/build/puppet/**/module/*.pp").each do |puppet_file|
      root_directory_length = ROOT_DIR.split('/').count
      module_name = puppet_file.split('/')[root_directory_length + 3]
      module_path = "#{ROOT_DIR}/mount/puppet/module/#{module_name}"
      if(Dir.exists?(module_path))
        Dir.mkdir("#{module_path}/manifests")
        puts "Moving #{puppet_file} to #{module_path}"
        FileUtils.copy(puppet_file, "#{module_path}/manifests")
      else
        Dir.mkdir("#{ROOT_DIR}/mount/puppet/module/#{module_name}")
        Dir.mkdir("#{ROOT_DIR}/mount/puppet/module/#{module_name}/manifests")
        puts "Moving #{puppet_file} to #{module_path}"
        FileUtils.copy(puppet_file, "#{module_path}/manifests")
      end
    end
    Dir.glob("#{ROOT_DIR}/modules/build/puppet/**/manifest/*.pp").each do |puppet_file|
      puts "Moving #{puppet_file} to mount/puppet/manifest."
      FileUtils.copy(puppet_file, "#{ROOT_DIR}/mount/puppet/manifest")
    end
  end

  def purge_puppet_files
    Dir.rm_rf("#{ROOT_DIR}/mount")

  end
end