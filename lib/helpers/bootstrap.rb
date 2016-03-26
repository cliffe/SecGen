require 'fileutils'
class Bootstrap

  def bootstrap
    puts 'Bootstrapping application..'

    if Dir.exists?(MOUNT_DIR)
      purge_puppet_files
    end

    create_directory_structure

    copy_manifests(VULNERABILITY_MANIFESTS)
    copy_modules(VULNERABILITY_MODULES)

    copy_manifests(SERVICE_MANIFESTS)
    copy_modules(SERVICE_MODULES)

    copy_manifests(BUILD_MANIFESTS)
    copy_modules(BUILD_MODULES)

    puts 'Application Bootstrapped'
  end

  def copy_manifests(path)
    Dir.glob(path).each do |file|
      puts "Moving #{file} to #{MOUNT_PUPPET_MANIFEST_DIR}"
      FileUtils.copy(file, MOUNT_PUPPET_MANIFEST_DIR)
    end

  end

  def copy_modules(path)
    Dir.glob(path).each do |directory|
      puts "Moving #{directory} to #{MOUNT_PUPPET_MODULE_DIR}"
      FileUtils.cp_r(directory, MOUNT_PUPPET_MODULE_DIR)
    end
  end

  def create_directory_structure
    print 'Mount directory not present, creating..'
    Dir.mkdir(MOUNT_DIR)
    print 'Creating Puppet directory..'
    Dir.mkdir(MOUNT_PUPPET_DIR)
    print 'Creating Puppet module directory..'
    Dir.mkdir(MOUNT_PUPPET_MODULE_DIR)
    print 'Creating Puppet manifest directory..'
    Dir.mkdir(MOUNT_PUPPET_MANIFEST_DIR)
    puts 'Complete'
  end

  def purge_puppet_files
    FileUtils.rm_rf(MOUNT_DIR)
  end
end