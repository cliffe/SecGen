require 'spec_helper_acceptance'

stop_test = true if UNSUPPORTED_PLATFORMS.any?{ |up| fact('osfamily') == up}

describe 'Tomcat Install source -defaults', :unless => stop_test do
  after :all do
    shell('pkill -f tomcat', :acceptable_exit_codes => [0,1])
    shell('rm -rf /opt/tomcat*', :acceptable_exit_codes => [0,1])
    shell('rm -rf /opt/apache-tomcat*', :acceptable_exit_codes => [0,1])
  end

  before :all do
    shell("curl -k -o /tmp/sample.war '#{SAMPLE_WAR}'", :acceptable_exit_codes => 0)
  end

  context 'Initial install Tomcat and verification' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class { 'tomcat':}
      class { 'java':}
      tomcat::instance { 'tomcat7':
        source_url    => '#{TOMCAT7_RECENT_SOURCE}',
        catalina_base => '/opt/apache-tomcat/tomcat7',
      }->
      tomcat::config::server { 'tomcat7':
        catalina_base => '/opt/apache-tomcat/tomcat7',
        port          => '8105',
      }->
      tomcat::config::server::connector { 'tomcat7-http':
        catalina_base         => '/opt/apache-tomcat/tomcat7',
        port                  => '8180',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '8543'
        },
      }->
      tomcat::config::server::connector { 'tomcat7-ajp':
        catalina_base         => '/opt/apache-tomcat/tomcat7',
        port                  => '8109',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '8543'
        },
      }->
      tomcat::war { 'tomcat7-sample.war':
        catalina_base => '/opt/apache-tomcat/tomcat7',
        war_source    => '/tmp/sample.war',
        war_name      => 'tomcat7-sample.war',
      }->
      tomcat::service { 'tomcat7':
        catalina_base => '/opt/apache-tomcat/tomcat7',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'Should be serving a page on port 8180' do
      shell('curl --retry 15 --retry-delay 4 localhost:8180') do |r|
        r.stdout.should match(/Apache Tomcat/)
      end
    end
    it 'Should be serving a JSP page from the war' do
      shell('curl localhost:8180/tomcat7-sample/hello.jsp') do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
  end

  context 'Stop tomcat' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class { 'tomcat':}
      tomcat::service{'tomcat7':
        catalina_base => '/opt/apache-tomcat/tomcat7',
        service_ensure => 'stopped',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'Should not be serving a page on port 8180' do
      shell('curl localhost:8180', :acceptable_exit_codes => 7)
    end
  end

  context 'Start Tomcat' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class { 'tomcat':}
      tomcat::service{'tomcat7':
        catalina_base => '/opt/apache-tomcat/tomcat7',
        service_ensure => 'running',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'Should be serving a page on port 8180' do
      shell('curl localhost:8180') do |r|
        r.stdout.should match(/Apache Tomcat/)
      end
    end
  end

  context 'un-deploy the war' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class { 'tomcat':}
      tomcat::war{'tomcat7-sample.war':
        catalina_base => '/opt/apache-tomcat/tomcat7',
        war_source    => '/tmp/sample.war',
        war_ensure => 'false',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'Should not have deployed the war' do
      shell('curl localhost:8180/tomcat7-sample/hello.jsp', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/The requested resource is not available/)
      end
    end
  end

  context 'remove the connector' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class { 'tomcat':}
      tomcat::config::server::connector{'tomcat7-http':
        catalina_base => '/opt/apache-tomcat/tomcat7',
        port => '8180',
        protocol => 'HTTP/1.1',
        connector_ensure => 'false',
        notify => Tomcat::Service['tomcat7'],
      }
      tomcat::service { 'tomcat7':
        catalina_base => '/opt/apache-tomcat/tomcat7'
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'Should not be abble to serve pages over port 8180' do
      shell('curl localhost:8180', :acceptable_exit_codes => 7)
    end
  end

  context 'Service Configuration' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{ 'tomcat':}
      tomcat::config::server::service{ 'org.apache.catalina.core.StandardService':
        catalina_base => '/opt/apache-tomcat/tomcat7',
        class_name => 'org.apache.catalina.core.StandardService',
        class_name_ensure => 'true',
        service_ensure  => 'true',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
    end
    it 'shoud have a service named FooBar and a class names FooBar' do
      shell('cat /opt/apache-tomcat/tomcat7/conf/server.xml', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/<Service name="org.apache.catalina.core.StandardService" className="org.apache.catalina.core.StandardService"><\/Service>/)
      end
    end
  end

  context 'add a valve' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{ 'tomcat':}
      tomcat::config::server::valve{'logger':
        catalina_base => '/opt/apache-tomcat/tomcat7',
        class_name => 'org.apache.catalina.valves.AccessLogValve',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
    end
    it 'should have changed the conf.xml file' do
      shell('cat /opt/apache-tomcat/tomcat7/conf/server.xml', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/<Valve className="org.apache.catalina.valves.AccessLogValve"><\/Valve>/)
      end
    end
  end

  context 'remove a valve' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{ 'tomcat':}
      tomcat::config::server::valve{'logger':
        catalina_base => '/opt/apache-tomcat/tomcat7',
        class_name => 'org.apache.catalina.valves.AccessLogValve',
        valve_ensure => 'false',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
    end
    it 'should have changed the conf.xml file' do
      shell('cat /opt/apache-tomcat/tomcat7/conf/server.xml', :acceptable_exit_codes => 0) do |r|
        r.stdout.should_not match(/<Valve className="org.apache.catalina.valves.AccessLogValve"><\/Valve>/)
      end
    end
  end

  context 'add engine and change settings' do
    it 'Should apply the manifest to create the engine without error' do
      pp = <<-EOS
      class{ 'tomcat':}
      tomcat::config::server::engine{'org.apache.catalina.core.StandardEngine':
        default_host => 'localhost',
        catalina_base => '/opt/apache-tomcat/tomcat7',
        background_processor_delay => 5,
        parent_service => 'org.apache.catalina.core.StandardService',
        start_stop_threads => 3,
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
    end
    it 'should have changed the conf.xml file' do
      #validation
      v = '<Service name="org.apache.catalina.core.StandardService" className="org.apache.catalina.core.StandardService"><Engine name="org.apache.catalina.core.StandardEngine" defaultHost="localhost" backgroundProcessorDelay="5" startStopThreads="3"><\/Engine>'
      shell('cat /opt/apache-tomcat/tomcat7/conf/server.xml', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/#{v}/)
      end
    end
    it 'Should apply the manifest to change the settings without error' do
      pp = <<-EOS
      class{ 'tomcat':}
      tomcat::config::server::engine{'org.apache.catalina.core.StandardEngine':
        default_host => 'localhost',
        catalina_base => '/opt/apache-tomcat/tomcat7',
        background_processor_delay => 999,
        parent_service => 'org.apache.catalina.core.StandardService',
        start_stop_threads => 555,
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
    end
    it 'should have changed the conf.xml file' do
      #validation
      v = '<Service name="org.apache.catalina.core.StandardService" className="org.apache.catalina.core.StandardService"><Engine name="org.apache.catalina.core.StandardEngine" defaultHost="localhost" backgroundProcessorDelay="999" startStopThreads="555"><\/Engine>'
      shell('cat /opt/apache-tomcat/tomcat7/conf/server.xml', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/#{v}/)
      end
    end
  end

  context 'add a host then change settings' do
    it 'Should apply the manifest to create the engine without error' do
      pp = <<-EOS
      class{ 'tomcat':}
      tomcat::config::server::host{'org.apache.catalina.core.StandardHost':
        app_base => '/opt/apache-tomcat/tomcat7/webapps',
        catalina_base => '/opt/apache-tomcat/tomcat7',
        host_name => 'hulk-smash',
        additional_attributes => {
          astrological_sign => 'scorpio',
          favorite-beer => 'PBR',
        },
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
    end
    it 'should have changed the conf.xml file' do
      #validation
      matches = ['<Host name="hulk-smash".*appBase="/opt/apache-tomcat/tomcat7/webapps".*></Host>','<Host name="hulk-smash".*astrological_sign="scorpio".*></Host>','<Host name="hulk-smash".*favorite-beer="PBR".*></Host>']
      shell('cat /opt/apache-tomcat/tomcat7/conf/server.xml', :acceptable_exit_codes => 0) do |r|
        matches.each do |m|
          r.stdout.should match(/#{m}/)
        end
      end
    end
    it 'Should apply the manifest to remove a engine attribute without error' do
      pp = <<-EOS
      class{ 'tomcat':}
      tomcat::config::server::host{'org.apache.catalina.core.StandardHost':
        app_base => '/opt/apache-tomcat/tomcat7/webapps',
        catalina_base => '/opt/apache-tomcat/tomcat7',
        host_name => 'hulk-smash',
        additional_attributes => {
          astrological_sign => 'scorpio',
        },
        attributes_to_remove => {
          favorite-beer => 'PBR',
        },
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
    end
    it 'should have changed the conf.xml file' do
      #validation
      v = '<Host name="hulk-smash" appBase="/opt/apache-tomcat/tomcat7/webapps" astrological_sign="scorpio"><\/Host>'
      shell('cat /opt/apache-tomcat/tomcat7/conf/server.xml', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/#{v}/)
      end
    end
  end

end






