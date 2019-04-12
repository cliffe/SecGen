require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'vsftpd' do

  let(:title) { 'vsftpd' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42' , :monitor_tool => 'puppi' } }

  describe 'Test standard installation' do
    it { should contain_package('vsftpd').with_ensure('present') }
    it { should contain_service('vsftpd').with_ensure('running') }
    it { should contain_service('vsftpd').with_enable('true') }
    it { should contain_file('vsftpd.conf').with_ensure('present') }
  end

  describe 'Test installation of a specific version' do
    let(:params) { {:version => '1.0.42' } }
    it { should contain_package('vsftpd').with_ensure('1.0.42') }
  end

  describe 'Test standard installation with monitoring and firewalling' do
    let(:params) { {:monitor => true , :firewall => true, :port => '42', :protocol => 'tcp' } }

    it { should contain_package('vsftpd').with_ensure('present') }
    it { should contain_service('vsftpd').with_ensure('running') }
    it { should contain_service('vsftpd').with_enable('true') }
    it { should contain_file('vsftpd.conf').with_ensure('present') }
    it 'should monitor the process' do
      content = catalogue.resource('monitor::process', 'vsftpd_process').send(:parameters)[:enable]
      content.should == true
    end
    it 'should place a firewall rule' do
      content = catalogue.resource('firewall', 'vsftpd_tcp_42').send(:parameters)[:enable]
      content.should == true
    end
  end

  describe 'Test decommissioning - absent' do
    let(:params) { {:absent => true, :monitor => true , :firewall => true, :port => '42', :protocol => 'tcp'} }

    it 'should remove Package[vsftpd]' do should contain_package('vsftpd').with_ensure('absent') end 
    it 'should stop Service[vsftpd]' do should contain_service('vsftpd').with_ensure('stopped') end
    it 'should not enable at boot Service[vsftpd]' do should contain_service('vsftpd').with_enable('false') end
    it 'should remove vsftpd configuration file' do should contain_file('vsftpd.conf').with_ensure('absent') end
    it 'should not monitor the process' do
      content = catalogue.resource('monitor::process', 'vsftpd_process').send(:parameters)[:enable]
      content.should == false
    end
    it 'should remove a firewall rule' do
      content = catalogue.resource('firewall', 'vsftpd_tcp_42').send(:parameters)[:enable]
      content.should == false
    end
  end

  describe 'Test decommissioning - disable' do
    let(:params) { {:disable => true, :monitor => true , :firewall => true, :port => '42', :protocol => 'tcp'} }

    it { should contain_package('vsftpd').with_ensure('present') }
    it 'should stop Service[vsftpd]' do should contain_service('vsftpd').with_ensure('stopped') end
    it 'should not enable at boot Service[vsftpd]' do should contain_service('vsftpd').with_enable('false') end
    it { should contain_file('vsftpd.conf').with_ensure('present') }
    it 'should not monitor the process' do
      content = catalogue.resource('monitor::process', 'vsftpd_process').send(:parameters)[:enable]
      content.should == false
    end
    it 'should remove a firewall rule' do
      content = catalogue.resource('firewall', 'vsftpd_tcp_42').send(:parameters)[:enable]
      content.should == false
    end
  end

  describe 'Test decommissioning - disableboot' do
    let(:params) { {:disableboot => true, :monitor => true , :firewall => true, :port => '42', :protocol => 'tcp'} }
  
    it { should contain_package('vsftpd').with_ensure('present') }
    it { should_not contain_service('vsftpd').with_ensure('present') }
    it { should_not contain_service('vsftpd').with_ensure('absent') }
    it 'should not enable at boot Service[vsftpd]' do should contain_service('vsftpd').with_enable('false') end
    it { should contain_file('vsftpd.conf').with_ensure('present') }
    it 'should not monitor the process locally' do
      content = catalogue.resource('monitor::process', 'vsftpd_process').send(:parameters)[:enable]
      content.should == false
    end
    it 'should keep a firewall rule' do
      content = catalogue.resource('firewall', 'vsftpd_tcp_42').send(:parameters)[:enable]
      content.should == true
    end
  end 

  describe 'Test customizations - template' do
    let(:params) { {:template => "vsftpd/spec.erb" , :options => { 'opt_a' => 'value_a' } } }

    it 'should generate a valid template' do
      content = catalogue.resource('file', 'vsftpd.conf').send(:parameters)[:content]
      content.should match "fqdn: rspec.example42.com"
    end
    it 'should generate a template that uses custom options' do
      content = catalogue.resource('file', 'vsftpd.conf').send(:parameters)[:content]
      content.should match "value_a"
    end

  end

  describe 'Test customizations - source' do
    let(:params) { {:source => "puppet://modules/vsftpd/spec" , :source_dir => "puppet://modules/vsftpd/dir/spec" , :source_dir_purge => true } }

    it 'should request a valid source ' do
      content = catalogue.resource('file', 'vsftpd.conf').send(:parameters)[:source]
      content.should == "puppet://modules/vsftpd/spec"
    end
    it 'should request a valid source dir' do
      content = catalogue.resource('file', 'vsftpd.dir').send(:parameters)[:source]
      content.should == "puppet://modules/vsftpd/dir/spec"
    end
    it 'should purge source dir if source_dir_purge is true' do
      content = catalogue.resource('file', 'vsftpd.dir').send(:parameters)[:purge]
      content.should == true
    end
  end

  describe 'Test customizations - custom class' do
    let(:params) { {:my_class => "vsftpd::spec" } }
    it 'should automatically include a custom class' do
      content = catalogue.resource('file', 'vsftpd.conf').send(:parameters)[:content]
      content.should match "fqdn: rspec.example42.com"
    end
  end

  describe 'Test service autorestart' do
    it { should contain_file('vsftpd.conf').with_notify('Service[vsftpd]') }
  end

  describe 'Test service autorestart' do
    let(:params) { {:service_autorestart => "no" } }

    it 'should not automatically restart the service, when service_autorestart => false' do
      content = catalogue.resource('file', 'vsftpd.conf').send(:parameters)[:notify]
      content.should be_nil
    end
  end

  describe 'Test Puppi Integration' do
    let(:params) { {:puppi => true, :puppi_helper => "myhelper"} }

    it 'should generate a puppi::ze define' do
      content = catalogue.resource('puppi::ze', 'vsftpd').send(:parameters)[:helper]
      content.should == "myhelper"
    end
  end

  describe 'Test Monitoring Tools Integration' do
    let(:params) { {:monitor => true, :monitor_tool => "puppi" } }

    it 'should generate monitor defines' do
      content = catalogue.resource('monitor::process', 'vsftpd_process').send(:parameters)[:tool]
      content.should == "puppi"
    end
  end

  describe 'Test Firewall Tools Integration' do
    let(:params) { {:firewall => true, :firewall_tool => "iptables" , :protocol => "tcp" , :port => "42" } }

    it 'should generate correct firewall define' do
      content = catalogue.resource('firewall', 'vsftpd_tcp_42').send(:parameters)[:tool]
      content.should == "iptables"
    end
  end

  describe 'Test OldGen Module Set Integration' do
    let(:params) { {:monitor => "yes" , :monitor_tool => "puppi" , :firewall => "yes" , :firewall_tool => "iptables" , :puppi => "yes" , :port => "42" , :protocol => 'tcp' } }

    it 'should generate monitor resources' do
      content = catalogue.resource('monitor::process', 'vsftpd_process').send(:parameters)[:tool]
      content.should == "puppi"
    end
    it 'should generate firewall resources' do
      content = catalogue.resource('firewall', 'vsftpd_tcp_42').send(:parameters)[:tool]
      content.should == "iptables"
    end
    it 'should generate puppi resources ' do 
      content = catalogue.resource('puppi::ze', 'vsftpd').send(:parameters)[:ensure]
      content.should == "present"
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :monitor => true , :ipaddress => '10.42.42.42' } }
    let(:params) { { :port => '42' , :monitor_tool => 'puppi' } }

    it 'should honour top scope global vars' do
      content = catalogue.resource('monitor::process', 'vsftpd_process').send(:parameters)[:enable]
      content.should == true
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :vsftpd_monitor => true , :ipaddress => '10.42.42.42' } }
    let(:params) { { :port => '42' , :monitor_tool => 'puppi' } }

    it 'should honour module specific vars' do
      content = catalogue.resource('monitor::process', 'vsftpd_process').send(:parameters)[:enable]
      content.should == true
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :monitor => false , :vsftpd_monitor => true , :ipaddress => '10.42.42.42' } }
    let(:params) { { :port => '42' , :monitor_tool => 'puppi' } }

    it 'should honour top scope module specific over global vars' do
      content = catalogue.resource('monitor::process', 'vsftpd_process').send(:parameters)[:enable]
      content.should == true
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :monitor => false , :ipaddress => '10.42.42.42' } }
    let(:params) { { :monitor => true , :firewall => true, :port => '42' , :monitor_tool => 'puppi' } }

    it 'should honour passed params over global vars' do
      content = catalogue.resource('monitor::process', 'vsftpd_process').send(:parameters)[:enable]
      content.should == true
    end
  end

end

