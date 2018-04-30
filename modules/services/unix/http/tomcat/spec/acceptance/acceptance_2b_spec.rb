require 'spec_helper_acceptance'

stop_test = true if UNSUPPORTED_PLATFORMS.any?{ |up| fact('osfamily') == up}

describe 'Two different installations with two instances each of Tomcat 6 in the same manifest', docker: true, :unless => stop_test do
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
      class { 'java':}
      tomcat::install { 'tomcat6':
        catalina_home => '/opt/apache-tomcat6',
        source_url    => '#{TOMCAT6_RECENT_SOURCE}',
      }
      tomcat::instance { 'tomcat6-first':
        catalina_home => '/opt/apache-tomcat6',
        catalina_base => '/opt/tomcat6-first',
      }
      tomcat::instance { 'tomcat6-second':
        catalina_home => '/opt/apache-tomcat6',
        catalina_base => '/opt/tomcat6-second',
      }
      tomcat::config::server { 'tomcat6-first':
        catalina_base => '/opt/tomcat6-first',
        port          => '8205',
      }
      tomcat::config::server { 'tomcat6-second':
        catalina_base => '/opt/tomcat6-second',
        port          => '8206',
      }
      tomcat::config::server::connector { 'tomcat6-first-http':
        catalina_base         => '/opt/tomcat6-first',
        port                  => '8280',
        protocol              => 'HTTP/1.1',
        purge_connectors      => true,
        additional_attributes => {
          'redirectPort' => '8643'
        },
      }
      tomcat::config::server::connector { 'tomcat6-first-ajp':
        catalina_base         => '/opt/tomcat6-first',
        port                  => '8209',
        protocol              => 'AJP/1.3',
        purge_connectors      => true,
        additional_attributes => {
          'redirectPort' => '8643'
        },
      }
      tomcat::config::server::connector { 'tomcat6-second-http':
        catalina_base         => '/opt/tomcat6-second',
        port                  => '8281',
        protocol              => 'HTTP/1.1',
        purge_connectors      => true,
        additional_attributes => {
          'redirectPort' => '8644'
        },
      }
      tomcat::config::server::connector { 'tomcat6-second-ajp':
        catalina_base         => '/opt/tomcat6-second',
        port                  => '8210',
        protocol              => 'AJP/1.3',
        purge_connectors      => true,
        additional_attributes => {
          'redirectPort' => '8644'
        },
      }
      tomcat::war { 'first tomcat6-sample.war':
        catalina_base => '/opt/tomcat6-first',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat6-sample.war',
      }
      tomcat::war { 'second tomcat6-sample.war':
        catalina_base => '/opt/tomcat6-second',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat6-sample.war',
      }


      tomcat::install { 'tomcat6039':
        catalina_home => '/opt/apache-tomcat6039',
        source_url    => '#{TOMCAT_LEGACY_SOURCE}',
      }
      tomcat::instance { 'tomcat6039-first':
        catalina_home => '/opt/apache-tomcat6039',
        catalina_base => '/opt/tomcat6039-first',
      }
      tomcat::instance { 'tomcat6039-second':
        catalina_home => '/opt/apache-tomcat6039',
        catalina_base => '/opt/tomcat6039-second',
      }
      tomcat::config::server { 'tomcat6039-first':
        catalina_base => '/opt/tomcat6039-first',
        port          => '8305',
      }
      tomcat::config::server { 'tomcat6039-second':
        catalina_base => '/opt/tomcat6039-second',
        port          => '8306',
      }
      tomcat::config::server::connector { 'tomcat6039-first-http':
        catalina_base         => '/opt/tomcat6039-first',
        port                  => '8380',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '8743'
        },
      }
      tomcat::config::server::connector { 'tomcat6039-second-http':
        catalina_base         => '/opt/tomcat6039-second',
        port                  => '8381',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '8744'
        },
      }
      tomcat::config::server::connector { 'tomcat6039-first-ajp':
        catalina_base         => '/opt/tomcat6039-first',
        port                  => '8309',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '8743'
        },
      }
      tomcat::config::server::connector { 'tomcat6039-second-ajp':
        catalina_base         => '/opt/tomcat6039-second',
        port                  => '8310',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '8744'
        },
      }
      tomcat::war { 'first tomcat6039-sample.war':
        catalina_base => '/opt/tomcat6039-first',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat6039-sample.war',
      }
      tomcat::war { 'second tomcat6039-sample.war':
        catalina_base => '/opt/tomcat6039-second',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat6039-sample.war',
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
      shell('sleep 15')
    end
    #test the war
    it 'tomcat6-first should have war deployed by default' do
      shell('curl localhost:8280/tomcat6-sample/hello.jsp', :acceptable_exit_codes => 0) do |r|
        expect(r.stdout).to match(/Sample Application JSP Page/)
      end
    end
    it 'tomcat6-second should have war deployed by default' do
      shell('curl localhost:8281/tomcat6-sample/hello.jsp', :acceptable_exit_codes => 0) do |r|
        expect(r.stdout).to match(/Sample Application JSP Page/)
      end
    end
    it 'tomcat6039-first should have war deployed by default' do
      shell('curl localhost:8380/tomcat6039-sample/hello.jsp', :acceptable_exit_codes => 0) do |r|
        expect(r.stdout).to match(/Sample Application JSP Page/)
      end
    end
    it 'tomcat6039-second should have war deployed by default' do
      shell('curl localhost:8381/tomcat6039-sample/hello.jsp', :acceptable_exit_codes => 0) do |r|
        expect(r.stdout).to match(/Sample Application JSP Page/)
      end
    end
  end

  context 'Stop tomcat service' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      tomcat::service { 'tomcat6-first':
        catalina_home  => '/opt/apache-tomcat6',
        catalina_base  => '/opt/tomcat6-first',
        service_ensure => 'false',
      }
      tomcat::service { 'tomcat6-second':
        catalina_home  => '/opt/apache-tomcat6',
        catalina_base  => '/opt/tomcat6-second',
        service_ensure => 'false',
      }
      tomcat::service { 'tomcat6039-first':
        catalina_home  => '/opt/apache-tomcat6039',
        catalina_base  => '/opt/tomcat6039-first',
        service_ensure => 'stopped',
      }
      tomcat::service { 'tomcat6039-second':
        catalina_home  => '/opt/apache-tomcat6039',
        catalina_base  => '/opt/tomcat6039-second',
        service_ensure => 'stopped',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'tomcat6-first should not be serving a page on port 8280' do
      shell('curl localhost:8280', :acceptable_exit_codes => 7)
    end
    it 'tomcat6-second should not be serving a page on port 8281' do
      shell('curl localhost:8281', :acceptable_exit_codes => 7)
    end
    it 'tomcat6039-first should not be serving a page on port 8380' do
      shell('curl localhost:8380', :acceptable_exit_codes => 7)
    end
    it 'tomcat6039-second should not be serving a page on port 8381' do
      shell('curl localhost:8381', :acceptable_exit_codes => 7)
    end
  end

  context 'Start Tomcat without war' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      Staging::File {
        curl_option => '-k',
      }
      tomcat::war { 'tomcat6039-sample.war':
        catalina_base => '/opt/tomcat6039-first',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat6039-sample.war',
        war_ensure    => 'absent',
      }->
      tomcat::service { 'tomcat6039-first':
        catalina_home  => '/opt/apache-tomcat6039',
        catalina_base  => '/opt/tomcat6039-first',
        service_ensure => 'true',
      }->
      tomcat::war { 'tomcat6-sample.war':
        catalina_base => '/opt/tomcat6-first',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat6-sample.war',
        war_ensure    => 'false',
      }->
      tomcat::service { 'tomcat6-first':
        catalina_home  => '/opt/apache-tomcat6',
        catalina_base  => '/opt/tomcat6-first',
        service_ensure => 'running',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'tomcat6-first should not display message when war is not deployed' do
      shell('curl localhost:8280/tomcat6-sample/hello.jsp') do |r|
        expect(r.stdout).to_not match(/Sample Application JSP Page/)
      end
    end
    it 'tomcat6039-first should not display message when war is not deployed' do
      shell('curl localhost:8380/tomcat6039-sample/hello.jsp') do |r|
        expect(r.stdout).to_not match(/Sample Application JSP Page/)
      end
    end
  end

  context 'deploy the war' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      Staging::File {
        curl_option => '-k',
      }
      tomcat::war { 'tomcat6-sample.war':
        catalina_base => '/opt/tomcat6-first',
        war_source    => '#{SAMPLE_WAR}',
        war_name      => 'tomcat6-sample.war',
        war_ensure    => 'present',
      }
      tomcat::war { 'tomcat6039-sample.war':
        catalina_base => '/opt/tomcat6039-first',
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
        expect(r.stdout).to match(/Sample Application JSP Page/)
      end
    end
    it 'tomcat6039 should be serving a war on port 8380' do
      shell('curl localhost:8380/tomcat6039-sample/hello.jsp') do |r|
        expect(r.stdout).to match(/Sample Application JSP Page/)
      end
    end
  end
end
