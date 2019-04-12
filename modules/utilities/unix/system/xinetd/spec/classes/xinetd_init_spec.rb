require 'spec_helper'

describe 'xinetd' do

  context 'When using default values' do
    let :facts do
      { :osfamily => 'Debian' }
    end
    it {
      should contain_package('xinetd')
      should contain_file('/etc/xinetd.conf')
      should contain_service('xinetd')
    }
    it {
      # Ensure that the config file allows xinetd to use its own defaults
      should contain_file('/etc/xinetd.conf').without_content(/enabled *=/)
      should contain_file('/etc/xinetd.conf').without_content(/disabled *=/)
      should contain_file('/etc/xinetd.conf').without_content(/log_type *=/)
      should contain_file('/etc/xinetd.conf').without_content(/log_on_failure *=/)
      should contain_file('/etc/xinetd.conf').without_content(/log_on_success *=/)
      should contain_file('/etc/xinetd.conf').without_content(/no_access *=/)
      should contain_file('/etc/xinetd.conf').without_content(/only_from *=/)
      should contain_file('/etc/xinetd.conf').without_content(/max_load *=/)
      should contain_file('/etc/xinetd.conf').without_content(/instances *=/)
      should contain_file('/etc/xinetd.conf').without_content(/per_source *=/)
      should contain_file('/etc/xinetd.conf').without_content(/bind *=/)
      should contain_file('/etc/xinetd.conf').without_content(/mdns *=/)
      should contain_file('/etc/xinetd.conf').without_content(/v6only *=/)
      should contain_file('/etc/xinetd.conf').without_content(/passenv *=/)
      should contain_file('/etc/xinetd.conf').without_content(/env *=/)
      should contain_file('/etc/xinetd.conf').without_content(/groups *=/)
      should contain_file('/etc/xinetd.conf').without_content(/umask *=/)
      should contain_file('/etc/xinetd.conf').without_content(/banner *=/)
      should contain_file('/etc/xinetd.conf').without_content(/banner_fail *=/)
      should contain_file('/etc/xinetd.conf').without_content(/banner_success *=/)
    }
  end

  context 'When overriding the default vaules' do
    let :facts do
      { :osfamily => 'Debian' }
    end
    let :params do
      { :enabled        => 'tftp nrpe',
        :disabled       => 'time echo',
        :log_type       => 'SYSLOG daemon info',
        :log_on_failure => 'HOST',
        :log_on_success => 'PID HOST DURATION EXIT',
        :no_access      => '128.138.209.10',
        :only_from      => '127.0.0.1',
        :max_load       => '2',
        :instances      => '50', 
        :per_source     => '50',
        :bind           => '0.0.0.0',
        :mdns           => 'yes',
        :v6only         => 'no',
        :env            => 'foo=bar',
        :passenv        => 'yes',
        :groups         => 'yes',
        :umask          => '002',
        :banner         => '/etc/banner',
        :banner_fail    => '/etc/banner.fail',
        :banner_success => '/etc/banner.good',
      }
    end
    it {
      # Ensure that the config file allows xinetd to use its own defaults
      should contain_file('/etc/xinetd.conf').with_content(/enabled *= tftp nrpe/)
      should contain_file('/etc/xinetd.conf').with_content(/disabled *= time echo/)
      should contain_file('/etc/xinetd.conf').with_content(/log_type *= SYSLOG daemon info/)
      should contain_file('/etc/xinetd.conf').with_content(/log_on_failure *= HOST/)
      should contain_file('/etc/xinetd.conf').with_content(/log_on_success *= PID HOST DURATION EXIT/)
      should contain_file('/etc/xinetd.conf').with_content(/no_access *= 128.138.209.10/)
      should contain_file('/etc/xinetd.conf').with_content(/only_from *= 127.0.0.1/)
      should contain_file('/etc/xinetd.conf').with_content(/max_load *= 2/)
      should contain_file('/etc/xinetd.conf').with_content(/instances *= 50/)
      should contain_file('/etc/xinetd.conf').with_content(/per_source *= 50/)
      should contain_file('/etc/xinetd.conf').with_content(/bind *= 0.0.0.0/)
      should contain_file('/etc/xinetd.conf').with_content(/mdns *= yes/)
      should contain_file('/etc/xinetd.conf').with_content(/v6only *= no/)
      should contain_file('/etc/xinetd.conf').with_content(/env *= foo=bar/)
      should contain_file('/etc/xinetd.conf').with_content(/passenv *= yes/)
      should contain_file('/etc/xinetd.conf').with_content(/passenv *= yes/)
      should contain_file('/etc/xinetd.conf').with_content(/groups *= yes/)
      should contain_file('/etc/xinetd.conf').with_content(/umask *= 002/)
      should contain_file('/etc/xinetd.conf').with_content(/banner *= \/etc\/banner/)
      should contain_file('/etc/xinetd.conf').with_content(/banner_fail *= \/etc\/banner\.fail/)
      should contain_file('/etc/xinetd.conf').with_content(/banner_success *= \/etc\/banner\.good/)
    }
  end

  context 'with defaults on Linux' do
    let :facts do
      { :osfamily => 'Debian' }
    end
    it {
      should contain_package('xinetd')
      should contain_file('/etc/xinetd.conf')
      should contain_file('/etc/xinetd.d').with_ensure('directory')
      should contain_service('xinetd')
    }
  end

  context 'with defaults on FreeBSD' do
    let :facts do
      { :osfamily => 'FreeBSD' }
    end
    it {
      should contain_package('security/xinetd')
      should contain_file('/usr/local/etc/xinetd.conf')
      should contain_file('/usr/local/etc/xinetd.d').with_ensure('directory')
      should contain_service('xinetd')
    }
  end

  context 'with managed confdir' do
    let :facts do
      { :osfamily => 'Debian' }
    end
    let :params do
      { :purge_confdir => true }
    end

    it {
      should contain_package('xinetd')
      should contain_file('/etc/xinetd.conf')
      should contain_file('/etc/xinetd.d').with_ensure('directory')
      should contain_file('/etc/xinetd.d').with_recurse(true)
      should contain_file('/etc/xinetd.d').with_purge(true)
      should contain_service('xinetd')
    }
  end
end
