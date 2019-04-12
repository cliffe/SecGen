require 'spec_helper_acceptance'

stop_test = true if UNSUPPORTED_PLATFORMS.any?{ |up| fact('osfamily') == up}

describe 'Two different instances of Tomcat 6 in the same manifest', :unless => stop_test do
  after :all do
    shell('pkill -f tomcat', :acceptable_exit_codes => [0,1])
    shell('rm -rf /opt/tomcat*', :acceptable_exit_codes => [0,1])
    shell('rm -rf /opt/apache-tomcat*', :acceptable_exit_codes => [0,1])
  end

  context 'Initial install Tomcat and verification' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      Staging::File {
        curl_option => '-k',
      }
      class { 'tomcat':}
      class { 'java':}
      tomcat::instance { 'tomcat6':
        source_url => '#{TOMCAT6_RECENT_SOURCE}',
        catalina_base => '/opt/apache-tomcat/tomcat6',
      }->
      tomcat::config::server { 'tomcat6':
        catalina_base => '/opt/apache-tomcat/tomcat6',
        port          => '8205',
      }->
      tomcat::config::server::connector { 'tomcat6-http':
        catalina_base         => '/opt/apache-tomcat/tomcat6',
        port                  => '8280',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '8643'
        },
      }->
      tomcat::config::server::connector { 'tomcat6-ajp':
        catalina_base         => '/opt/apache-tomcat/tomcat6',
        port                  => '8209',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '8643'
        },
      }->
      tomcat::war { 'tomcat6-sample.war':
        catalina_base => '/opt/apache-tomcat/tomcat6',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat6-sample.war',
      }->
      tomcat::service { 'tomcat6':
        catalina_base => '/opt/apache-tomcat/tomcat6'
      }

      tomcat::instance { 'tomcat6039':
        source_url => '#{TOMCAT_LEGACY_SOURCE}',
        catalina_base => '/opt/apache-tomcat/tomcat6039',
      }->
      tomcat::config::server { 'tomcat6039':
        catalina_base => '/opt/apache-tomcat/tomcat6039',
        port          => '8305',
      }->
      tomcat::config::server::connector { 'tomcat6039-http':
        catalina_base         => '/opt/apache-tomcat/tomcat6039',
        port                  => '8380',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '8743'
        },
      }->
      tomcat::config::server::connector { 'tomcat6039-ajp':
        catalina_base         => '/opt/apache-tomcat/tomcat6039',
        port                  => '8309',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '8743'
        },
      }->
      tomcat::war { 'tomcat6039-sample.war':
        catalina_base => '/opt/apache-tomcat/tomcat6039',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat6039-sample.war',
      }->
      tomcat::service { 'tomcat6039':
        catalina_base => '/opt/apache-tomcat/tomcat6039'
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    # test the server
    it 'tomcat6 should be serving a page on port 8280' do
      shell('curl localhost:8280', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/Apache Tomcat/)
      end
    end
    it 'tomcat6039 should be serving a page on port 8380' do
      shell('curl localhost:8380', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/Apache Tomcat/)
      end
    end
    #test the war
    it 'tomcat6 should have war deployed by default' do
      shell('curl localhost:8280/tomcat6-sample/hello.jsp', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
    it 'tomcat6039 should have war deployed by default' do
      shell('curl localhost:8380/tomcat6039-sample/hello.jsp', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
  end

  context 'Stop tomcat service' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{ 'tomcat':}
      tomcat::service { 'tomcat6039':
        catalina_base => '/opt/apache-tomcat/tomcat6039',
        service_ensure => 'stopped',
      }
      tomcat::service { 'tomcat6':
        catalina_base => '/opt/apache-tomcat/tomcat6',
        service_ensure => 'false',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'tomcat6 should not be serving a page on port 8280' do
      shell('curl localhost:8280', :acceptable_exit_codes => 7)
    end
    it 'tomcat6039 should not be serving a page on port 8380' do
      shell('curl localhost:8380', :acceptable_exit_codes => 7)
    end
  end

  context 'Start Tomcat without war' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      Staging::File {
        curl_option => '-k',
      }
      class{ 'tomcat':}
      tomcat::war { 'tomcat6039-sample.war':
        catalina_base => '/opt/apache-tomcat/tomcat6039',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat6039-sample.war',
        war_ensure    => 'absent',
      }->
      tomcat::service { 'tomcat6039':
        catalina_base => '/opt/apache-tomcat/tomcat6039',
        service_ensure => 'true',
      }
      tomcat::war { 'tomcat6-sample.war':
        catalina_base => '/opt/apache-tomcat/tomcat6',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat6-sample.war',
        war_ensure    => 'false',
      }->
      tomcat::service { 'tomcat6':
        catalina_base => '/opt/apache-tomcat/tomcat6',
        service_ensure => 'running',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'tomcat6 should be display friendly message when war is not deployed' do
      shell('curl localhost:8280/tomcat6-sample/hello.jsp') do |r|
        r.stdout.should match(/The requested resource is not available/)
      end
    end
    it 'tomcat6039 should be display friendly message when war is not deployed' do
      shell('curl localhost:8380/tomcat6039-sample/hello.jsp') do |r|
        r.stdout.should match(/The requested resource is not available/)
      end
    end
  end

  context 'deploy the war' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      Staging::File {
        curl_option => '-k',
      }
      class{ 'tomcat':}
      tomcat::war { 'tomcat6-sample.war':
        catalina_base => '/opt/apache-tomcat/tomcat6',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat6-sample.war',
        war_ensure    => 'present',
      }
      tomcat::war { 'tomcat6039-sample.war':
        catalina_base => '/opt/apache-tomcat/tomcat6039',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat6039-sample.war',
        war_ensure    => 'true',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'tomcat6 should be serving a war on port 8280' do
      shell('curl localhost:8280/tomcat6-sample/hello.jsp') do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
    it 'tomcat6039 should be serving a war on port 8380' do
      shell('curl localhost:8380/tomcat6039-sample/hello.jsp') do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
  end

end
