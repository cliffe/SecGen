require 'spec_helper_acceptance'

#fact based two stage confine

#confine array
confine_array = [
  (fact('operatingsystem') == 'Ubuntu'  &&  fact('operatingsystemrelease') == '10.04'),
  (fact('osfamily') == 'RedHat'         &&  fact('operatingsystemmajrelease') == '5'),
  (fact('operatingsystem') == 'Debian'  &&  fact('operatingsystemmajrelease') == '6'),
  fact('osfamily') == 'Suse'
]

stop_test = false
stop_test = true if UNSUPPORTED_PLATFORMS.any?{ |up| fact('osfamily') == up} || confine_array.any?

describe 'Acceptance case one', :unless => stop_test do
  after :all do
    shell('pkill -f tomcat', :acceptable_exit_codes => [0,1])
    shell('rm -rf /opt/tomcat*', :acceptable_exit_codes => [0,1])
    shell('rm -rf /opt/apache-tomcat*', :acceptable_exit_codes => [0,1])
  end

  context 'Initial install Tomcat and verification' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{'tomcat':}
      class{'java':}
      class{'gcc':}

      if $::operatingsystemmajrelease == '16.04' {
        $java_home = "/usr/lib/jvm/java-8-openjdk-${::architecture}"
      } else {
        $java_home = $::osfamily ? {
          'RedHat' => '/etc/alternatives/java_sdk',
          'Debian' => "/usr/lib/jvm/java-7-openjdk-${::architecture}",
          default  => undef
        }
      }

      tomcat::instance { 'tomcat_one':
        source_url    => '#{TOMCAT8_RECENT_SOURCE}',
        catalina_base => '/opt/apache-tomcat/tomcat8-jsvc',
      }->
      staging::extract { 'commons-daemon-native.tar.gz':
        source => "/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-native.tar.gz",
        target => "/opt/apache-tomcat/tomcat8-jsvc/bin",
        unless => "test -d /opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src",
      }->
      exec { 'configure jsvc':
        command  => "JAVA_HOME=${java_home} configure --with-java=${java_home}",
        creates  => "/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src/unix/Makefile",
        cwd      => "/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src/unix",
        path     => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src/unix",
        require  => [ Class['gcc'], Class['java'] ],
        provider => shell,
      }->
      exec { 'make jsvc':
        command  => 'make',
        creates  => "/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src/unix/jsvc",
        cwd      => "/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src/unix",
        path     => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src/unix",
        provider => shell,
      }->
      file { 'jsvc':
        ensure => link,
        path   => "/opt/apache-tomcat/tomcat8-jsvc/bin/jsvc",
        target => "/opt/apache-tomcat/tomcat8-jsvc/bin/commons-daemon-1.0.15-native-src/unix/jsvc",
      }->
      tomcat::config::server { 'tomcat8-jsvc':
        catalina_base => '/opt/apache-tomcat/tomcat8-jsvc',
        port          => '80',
      }->
      tomcat::config::server::connector { 'tomcat8-jsvc':
        catalina_base         => '/opt/apache-tomcat/tomcat8-jsvc',
        port                  => '80',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '443'
        },
        notify                => Tomcat::Service['jsvc-default'],
      }->
      tomcat::config::server::connector { 'tomcat8-ajp':
        catalina_base         => '/opt/apache-tomcat/tomcat8-jsvc',
        port                  => '8309',
        protocol              => 'AJP/1.3',
        additional_attributes => {
          'redirectPort' => '443'
        },
        connector_ensure => 'false',
      }->
      tomcat::war { 'war_one.war':
        catalina_base => '/opt/apache-tomcat/tomcat8-jsvc',
        war_source    => '#{SAMPLE_WAR}',
      }->
      tomcat::setenv::entry { 'JAVA_HOME':
        base_path => '/opt/apache-tomcat/tomcat8-jsvc/bin',
        value     => $java_home,
      }->
      tomcat::service { 'jsvc-default':
        catalina_base => '/opt/apache-tomcat/tomcat8-jsvc',
        java_home     => $java_home,
        use_jsvc      => true,
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'Should be serving a page on port 80' do
      shell('curl localhost:80/war_one/hello.jsp', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
  end

  context 'Stop tomcat with verification!!!' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{ 'tomcat':}
      tomcat::service{ 'jsvc-default':
        service_ensure => stopped,
        catalina_base  => '/opt/apache-tomcat/tomcat8-jsvc',
        use_jsvc       => true,
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'Should not be serving a page on port 80' do
      shell('curl localhost:80/war_one/hello.jsp', :acceptable_exit_codes => 7)
    end
  end

  context 'Start Tomcat with verification' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{ 'tomcat':}

      if $::operatingsystemmajrelease == '16.04' {
        $java_home = "/usr/lib/jvm/java-8-openjdk-${::architecture}"
      } else {
        $java_home = $::osfamily ? {
          'RedHat' => '/etc/alternatives/java_sdk',
          'Debian' => "/usr/lib/jvm/java-7-openjdk-${::architecture}",
          default  => undef
        }
      }

      tomcat::service{ 'jsvc-default':
        catalina_base  => '/opt/apache-tomcat/tomcat8-jsvc',
        service_ensure => true,
        use_jsvc       => true,
        java_home      => $java_home,
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'Should be serving a page on port 80' do
      shell('curl localhost:80/war_one/hello.jsp', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/Sample Application JSP Page/)
      end
    end
  end

  context 'un-deploy the war with verification' do
    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{ 'tomcat':}
      tomcat::war { 'war_one.war':
        catalina_base => '/opt/apache-tomcat/tomcat8-jsvc',
        war_source => '#{SAMPLE_WAR}',
        war_ensure => 'false',
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'Should not have deployed the war' do
      shell('curl localhost:80/war_one/hello.jsp', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/The requested resource is not available./)
      end
    end
    it 'Should still have the server running on port 80' do
      shell('curl localhost:80', :acceptable_exit_codes => 0) do |r|
        r.stdout.should match(/Apache Tomcat/)
      end
    end
  end

  context 'remove the connector with verification' do

    it 'Should apply the manifest without error' do
      pp = <<-EOS
      class{ 'tomcat':}

      if $::operatingsystemmajrelease == '16.04' {
        $java_home = "/usr/lib/jvm/java-8-openjdk-${::architecture}"
      } else {
        $java_home = $::osfamily ? {
          'RedHat' => '/etc/alternatives/java_sdk',
          'Debian' => "/usr/lib/jvm/java-7-openjdk-${::architecture}",
          default  => undef
        }
      }

      tomcat::config::server::connector { 'tomcat8-jsvc':
        catalina_base         => '/opt/apache-tomcat/tomcat8-jsvc',
        port                  => '80',
        protocol              => 'HTTP/1.1',
        additional_attributes => {
          'redirectPort' => '443'
        },
        connector_ensure => 'absent',
        notify => Tomcat::Service['jsvc-default']
      }
      tomcat::service { 'jsvc-default':
        catalina_base => '/opt/apache-tomcat/tomcat8-jsvc',
        java_home     => $java_home,
        use_jsvc      => true,
      }
      EOS
      apply_manifest(pp, :catch_failures => true, :acceptable_exit_codes => [0,2])
      shell('sleep 15')
    end
    it 'Should not be able to serve pages over port 80' do
      shell('curl localhost:80', :acceptable_exit_codes => 7)
    end
  end

end
