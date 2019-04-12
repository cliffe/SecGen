require 'spec_helper'
describe 'ruby', :type => :class do

  context 'On the Amazon operating system' do
    let :facts do
      {
        :osfamily   => 'Amazon',
      }
    end
    it { should contain_class('ruby::params') }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => 'installed',
        'name'    => 'rubygems',
        'require' => 'Package[ruby]',
      })
    }
    it { should_not contain_package('ruby-switch') }
    it { should_not contain_package('rubygems-integration') }
    it { should_not contain_package('rubygems-update') }
    it { should_not contain_exec('ruby::update_rubygems') }
    it { should_not contain_exec('switch_ruby') }
    it { should_not contain_file('ruby_bin') }
    it { should_not contain_file('gem_bin') }

    describe 'when passed true to update rubygems' do
      let :params do
        {
          :rubygems_update => 'true'
        }
      end
      it {
        should contain_package('rubygems-update').with({
          'ensure'    => 'installed',
          'require'   => 'Package[rubygems]',
          'provider'  => 'gem',
          'notify'    => 'Exec[ruby::update_rubygems]'
        })
      }
      it {
        should contain_exec('ruby::update_rubygems').with({
          'path'        => '/usr/local/bin:/usr/bin:/bin',
          'command'     => 'update_rubygems',
          'refreshonly' => true
        })
      }
    end

    describe 'when passed a custom rubygem version' do
      let :params do
        {
          :gems_version => '1.8.7'
        }
      end
      it {
        should contain_package('rubygems').with({
          'ensure'    => '1.8.7'
        })
      }
      it { should_not contain_package('rubygems-update') }
      describe 'with rubygems_update set to true' do
        let :params do
          {
            :gems_version    => '1.8.7',
            :rubygems_update => 'true'
          }
        end
        it {
          should contain_package('rubygems-update').with({
            'ensure' => '1.8.7'
          })
        }
      end
    end

    describe 'when given ruby and rubygem versions' do
      let :params do
        {
          :gems_version => '1.8.6',
          :version      => '1.8.7'
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby'
        })
      }
      it { should_not contain_package('rubygems-update') }

      describe 'with rubygems_update set to true' do
        let :params do
          {
            :gems_version    => '1.8.6',
            :version         => '1.8.7',
            :rubygems_update => 'true'
          }
        end
        it {
          should contain_package('rubygems-update').with({
            'ensure'    => '1.8.6'
          })
        }
      end
    end

    describe 'with a custom ruby package' do
      let :params do
        {
          :ruby_package => 'sparkly-ruby'
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'sparkly-ruby'
        })
      }
    end

    describe 'with a custom rubygems package' do
      let :params do
        {
          :rubygems_package => 'sparkly-rubygems'
        }
      end
      it {
        should contain_package('rubygems').with({
          'name'    => 'sparkly-rubygems',
        })
      }
    end

    describe 'with ruby 1.9.1' do
      let :params do
        {
          :version      => '1.9.1'
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby'
        })
      }
    end

    describe 'with ruby 2.0' do
      let :params do
        {
          :version      => '2.0'
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby'
        })
      }
    end

    describe 'when given a rubygem version and disable rubygems update' do
      let :params do
        {
          :gems_version     => '1.8.7',
          :rubygems_update  => false
        }
      end
      it {
        should contain_package('rubygems').with({
          'ensure'  => '1.8.7',
          'require' => 'Package[ruby]'
        })
      }
      it { should_not contain_package('rubygems-update') }
      it { should_not contain_exec('ruby::update_rubygems') }
    end

    describe 'when using the latest release' do
      let :params do
        {
          :latest_release  => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'latest'
        })
      }
    end

    describe 'when using ruby-switch' do
      let :params do
        {
          :switch  => true
        }
      end
      it { should_not contain_package('ruby-switch') }
      it { should_not contain_exec('switch_ruby') }
      it { should_not contain_file('ruby_bin') }
      it { should_not contain_file('gem_bin') }
    end

    describe 'when setting the system default' do
      let :params do
        {
          :set_system_default  => true
        }
      end
      it { should_not contain_package('ruby-switch') }
      it { should_not contain_exec('switch_ruby') }
      it { should_not contain_file('ruby_bin') }
      it { should_not contain_file('gem_bin') }
    end

    describe 'when using rubygem package integrations' do
      let :params do
        {
          :gem_integration => true
        }
      end
      it { should_not contain_package('rubygems-integration') }
    end

  end

  context 'On a RedHat family operating system' do
    let :facts do
      {
        :osfamily   => 'RedHat',
      }
    end
    it { should contain_class('ruby::params') }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => 'installed',
        'name'    => 'rubygems',
        'require' => 'Package[ruby]',
      })
    }

    it { should_not contain_package('ruby-switch') }
    it { should_not contain_package('rubygems-integration') }
    it { should_not contain_package('rubygems-update') }
    it { should_not contain_exec('ruby::update_rubygems') }
    it { should_not contain_exec('switch_ruby') }
    it { should_not contain_file('ruby_bin') }
    it { should_not contain_file('gem_bin') }

    describe 'when rubygems_update is set to true' do
      let :params do
        {
          :rubygems_update => 'true'
        }
      end
      it {
        should contain_package('rubygems-update').with({
          'ensure'    => 'installed',
          'require'   => 'Package[rubygems]',
          'provider'  => 'gem',
          'notify'    => 'Exec[ruby::update_rubygems]'
        })
      }
      it {
        should contain_exec('ruby::update_rubygems').with({
          'path'        => '/usr/local/bin:/usr/bin:/bin',
          'command'     => 'update_rubygems',
          'refreshonly' => true
        })
      }
    end

    describe 'when passed a custom rubygem version' do
      let :params do
        {
          :gems_version => '1.8.7'
        }
      end
      it {
        should contain_package('rubygems').with({
          'ensure'    => '1.8.7'
        })
      }
      it { should_not contain_package('rubygems-update') }

      describe 'when rubygems_update is set to true' do
        let :params do
          {
            :gems_version => '1.8.7',
            :rubygems_update => 'true'
          }
        end
        it {
          should contain_package('rubygems-update').with({
            'ensure'    => '1.8.7'
          })
        }
      end
    end

    describe 'when given ruby and rubygem versions' do
      let :params do
        {
          :gems_version => '1.8.6',
          :version      => '1.8.7'
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby'
        })
      }
      it { should_not contain_package('rubygems-update') }

      describe 'when rubygems_update is set to true' do
        let :params do
          {
            :gems_version    => '1.8.6',
            :version         => '1.8.7',
            :rubygems_update => 'true'
          }
        end
        it {
          should contain_package('rubygems-update').with({
            'ensure'    => '1.8.6'
          })
        }
      end
    end

    describe 'with a custom ruby package' do
      let :params do
        {
          :ruby_package => 'sparkly-ruby'
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'sparkly-ruby'
        })
      }
    end

    describe 'with a custom rubygems package' do
      let :params do
        {
          :rubygems_package => 'sparkly-rubygems'
        }
      end
      it {
        should contain_package('rubygems').with({
          'name'    => 'sparkly-rubygems',
        })
      }
    end

    describe 'with ruby 1.9.1' do
      let :params do
        {
          :version      => '1.9.1'
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby'
        })
      }
    end

    describe 'with ruby 2.0' do
      let :params do
        {
          :version      => '2.0'
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby'
        })
      }
    end

    describe 'when given a rubygem version and disable rubygems update' do
      let :params do
        {
          :gems_version     => '1.8.7',
          :rubygems_update  => false
        }
      end
      it {
        should contain_package('rubygems').with({
          'ensure'  => '1.8.7',
          'require' => 'Package[ruby]'
        })
      }
      it { should_not contain_package('rubygems-update') }
      it { should_not contain_exec('ruby::update_rubygems') }
    end

    describe 'when using the latest release' do
      let :params do
        {
          :latest_release  => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'latest'
        })
      }
    end

    describe 'when using ruby-switch' do
      let :params do
        {
          :switch  => true
        }
      end
      it { should_not contain_package('ruby-switch') }
      it { should_not contain_exec('switch_ruby') }
      it { should_not contain_file('ruby_bin') }
      it { should_not contain_file('gem_bin') }
    end

    describe 'when setting the system default' do
      let :params do
        {
          :set_system_default  => true
        }
      end
      it { should_not contain_package('ruby-switch') }
      it { should_not contain_exec('switch_ruby') }
      it { should_not contain_file('ruby_bin') }
      it { should_not contain_file('gem_bin') }
    end

    describe 'when using rubygem package integrations' do
      let :params do
        {
          :gem_integration => true
        }
      end
      it { should_not contain_package('rubygems-integration') }
    end

  end

  context 'On a Debian family operating system' do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '6.0',
      }
    end
    it { should contain_class('ruby::params') }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => 'installed',
        'name'    => 'rubygems',
        'require' => 'Package[ruby]',
      })
    }
    it { should_not contain_package('rubygems-update') }
    it { should_not contain_exec('ruby::update_rubygems') }
    it { should_not contain_package('ruby-switch') }
    it { should_not contain_exec('switch_ruby') }
    it { should_not contain_file('ruby_bin') }
    it { should_not contain_file('gem_bin') }

    describe 'with a custom ruby package' do
      let :params do
        {
          :ruby_package => 'sparkly-ruby'
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'sparkly-ruby'
        })
      }
    end

    describe 'with a custom rubygems package' do
      let :params do
        {
          :rubygems_package => 'sparkly-rubygems'
        }
      end
      it {
        should contain_package('rubygems').with({
          'name'    => 'sparkly-rubygems',
        })
      }
    end

    describe 'when using the latest release' do
      let :params do
        {
          :latest_release  => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'latest'
        })
      }
    end

    describe 'with ruby 1.8 with switch' do
      let :params do
        {
          :version      => '1.8',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.8'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.8',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.8',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 1.9.1 with switch' do
      let :params do
        {
          :version      => '1.9.1',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.9.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.9.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.9.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.0 with switch' do
      let :params do
        {
          :version      => '2.0',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.0'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.0',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.0',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.1 with switch' do
      let :params do
        {
          :version      => '2.1',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 1.8 with set_system_default' do
      let :params do
        {
          :version            => '1.8',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.8'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.8',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.8',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 1.9.1 with set_system_default' do
      let :params do
        {
          :version            => '1.9.1',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.9.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.9.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.9.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.0 with set_system_default' do
      let :params do
        {
          :version            => '2.0',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.0'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.0',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.0',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.1 with set_system_default' do
      let :params do
        {
          :version            => '2.1',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

  end

  context 'On Ubuntu 12.04LTS (Precise Pangolin)' do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
        :operatingsystemrelease => '12.04'
      }
    end
    it { should contain_class('ruby::params') }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => 'installed',
        'name'    => 'rubygems',
        'require' => 'Package[ruby]',
      })
    }
    it { should_not contain_package('rubygems-update') }
    it { should_not contain_exec('ruby::update_rubygems') }
    it { should_not contain_package('ruby-switch') }
    it { should_not contain_exec('switch_ruby') }
    it { should_not contain_file('ruby_bin') }
    it { should_not contain_file('gem_bin') }

    describe 'with a custom ruby package' do
      let :params do
        {
          :ruby_package => 'sparkly-ruby'
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'sparkly-ruby'
        })
      }
    end

    describe 'with a custom rubygems package' do
      let :params do
        {
          :rubygems_package => 'sparkly-rubygems'
        }
      end
      it {
        should contain_package('rubygems').with({
          'name'    => 'sparkly-rubygems',
        })
      }
    end

    describe 'when using the latest release' do
      let :params do
        {
          :latest_release  => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'latest'
        })
      }
    end

    describe 'with ruby 1.8 with switch' do
      let :params do
        {
          :version      => '1.8',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.8'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.8',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.8',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 1.9.1 with switch' do
      let :params do
        {
          :version      => '1.9.1',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.9.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.9.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.9.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.0 with switch' do
      let :params do
        {
          :version      => '2.0',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.0'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.0',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.0',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.1 with switch' do
      let :params do
        {
          :version      => '2.1',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 1.8 with set_system_default' do
      let :params do
        {
          :version            => '1.8',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.8'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.8',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.8',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 1.9.1 with set_system_default' do
      let :params do
        {
          :version            => '1.9.1',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.9.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.9.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.9.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.0 with set_system_default' do
      let :params do
        {
          :version            => '2.0',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.0'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.0',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.0',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.1 with set_system_default' do
      let :params do
        {
          :version            => '2.1',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

  end

  context 'On Ubuntu 13.10 (Saucy Salamander)' do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
        :operatingsystemrelease => '13.10'
      }
    end
    it { should contain_class('ruby::params') }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => 'installed',
        'name'    => 'rubygems',
        'require' => 'Package[ruby]',
      })
    }
    it { should_not contain_package('rubygems-update') }
    it { should_not contain_exec('ruby::update_rubygems') }
    it { should_not contain_package('ruby-switch') }
    it { should_not contain_exec('switch_ruby') }
    it { should_not contain_file('ruby_bin') }
    it { should_not contain_file('gem_bin') }

    describe 'with a custom ruby package' do
      let :params do
        {
          :ruby_package => 'sparkly-ruby'
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'sparkly-ruby'
        })
      }
    end

    describe 'with a custom rubygems package' do
      let :params do
        {
          :rubygems_package => 'sparkly-rubygems'
        }
      end
      it {
        should contain_package('rubygems').with({
          'name'    => 'sparkly-rubygems',
        })
      }
    end

    describe 'when using the latest release' do
      let :params do
        {
          :latest_release  => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'latest'
        })
      }
    end

    describe 'with ruby 1.8 with switch' do
      let :params do
        {
          :version      => '1.8',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.8'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.8',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.8',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 1.9.1 with switch' do
      let :params do
        {
          :version      => '1.9.1',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.9.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.9.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.9.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.0 with switch' do
      let :params do
        {
          :version      => '2.0',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.0'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.0',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.0',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.1 with switch' do
      let :params do
        {
          :version      => '2.1',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 1.8 with set_system_default' do
      let :params do
        {
          :version            => '1.8',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.8'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.8',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.8',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 1.9.1 with set_system_default' do
      let :params do
        {
          :version            => '1.9.1',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.9.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.9.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.9.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.0 with set_system_default' do
      let :params do
        {
          :version            => '2.0',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.0'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.0',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.0',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.1 with set_system_default' do
      let :params do
        {
          :version            => '2.1',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

  end

  context 'On Ubuntu 14.04LTS (Trusty Tahr' do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
        :operatingsystemrelease => '14.04'
      }
    end
    it { should contain_class('ruby::params') }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => 'installed',
        'name'    => 'ruby1.9.1-full',
        'require' => 'Package[ruby]',
      })
    }
    it { should_not contain_package('rubygems-update') }
    it { should_not contain_exec('ruby::update_rubygems') }
    it { should_not contain_package('ruby-switch') }
    it { should_not contain_exec('switch_ruby') }
    it { should_not contain_file('ruby_bin') }
    it { should_not contain_file('gem_bin') }

    describe 'with a custom ruby package' do
      let :params do
        {
          :ruby_package => 'sparkly-ruby'
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'sparkly-ruby'
        })
      }
    end

    describe 'with a custom rubygems package' do
      let :params do
        {
          :rubygems_package => 'sparkly-rubygems'
        }
      end
      it {
        should contain_package('rubygems').with({
          'name'    => 'sparkly-rubygems',
        })
      }
    end

    describe 'when using the latest release' do
      let :params do
        {
          :latest_release  => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'latest'
        })
      }
    end

    describe 'with ruby 1.8 with switch' do
      let :params do
        {
          :version      => '1.8',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.8'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.8',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.8',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 1.9.1 with switch' do
      let :params do
        {
          :version      => '1.9.1',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.9.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.9.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.9.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.0 with switch' do
      let :params do
        {
          :version      => '2.0',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.0'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.0',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.0',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.1 with switch' do
      let :params do
        {
          :version      => '2.1',
          :switch       => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 1.8 with set_system_default' do
      let :params do
        {
          :version            => '1.8',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.8'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.8',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.8',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 1.9.1 with set_system_default' do
      let :params do
        {
          :version            => '1.9.1',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby1.9.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby1.9.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem1.9.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.0 with set_system_default' do
      let :params do
        {
          :version            => '2.0',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.0'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.0',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.0',
          'require' => 'Package[rubygems]'
        } )
      }
    end

    describe 'with ruby 2.1 with set_system_default' do
      let :params do
        {
          :version            => '2.1',
          :set_system_default => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'installed',
          'name'    => 'ruby2.1'
        })
      }
      it {
        should contain_file('ruby_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/ruby',
          'target'  => '/usr/bin/ruby2.1',
          'require' => 'Package[ruby]'
        } )
      }
      it {
        should contain_file('gem_bin').with({
          'ensure'  => 'link',
          'path'    => '/usr/bin/gem',
          'target'  => '/usr/bin/gem2.1',
          'require' => 'Package[rubygems]'
        } )
      }
    end

  end

  context 'On a Archlinux family operating system' do
    let :facts do
      {
        :osfamily               => 'Archlinux',
        :operatingsystem        => 'Archlinux',
      }
    end
    it { should contain_class('ruby::params') }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby',
      })
    }
    it { should_not contain_package('rubygems') }
    it { should_not contain_package('rubygems-update') }
    it { should_not contain_exec('ruby::update_rubygems') }
    it { should_not contain_package('ruby-switch') }
    it { should_not contain_exec('switch_ruby') }
    it { should_not contain_file('ruby_bin') }
    it { should_not contain_file('gem_bin') }

    describe 'when using the latest release' do
      let :params do
        {
          :latest_release  => true
        }
      end
      it {
        should contain_package('ruby').with({
          'ensure'  => 'latest'
        })
      }
    end
  end

  context 'With an Unkown operating system' do
    let :facts do
      {
        :osfamily   => 'Unknown',
      }
    end
    it do
      expect {
        should contain_class('ruby::params')
      }.to raise_error(Puppet::Error, /Unsupported OS family: Unknown/)
    end
  end

end
