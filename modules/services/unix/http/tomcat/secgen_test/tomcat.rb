require_relative '../../../../../lib/post_provision_test'

class TomcatTest < PostProvisionTest
  def initialize
    self.module_name = 'tomcat'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) { test_local_command('tomcat installed?', 'test -d /opt/tomcat && echo /opt/tomcat', '/opt/tomcat') }
    tier(1) { test_local_command('catalina.sh exists?', 'test -x /opt/tomcat/bin/catalina.sh && echo ok', 'ok') }
    tier(1) { test_local_command('tomcat user exists', 'id tomcat', 'tomcat') }
    tier(1) { test_local_command('install owned by tomcat', 'stat -c %U /opt/tomcat/bin/catalina.sh', 'tomcat') }
    tier(1) { test_local_command('webapps present', 'test -d /opt/tomcat/webapps && echo ok', 'ok') }
    tier(2) { test_service_up(port: 8080) }
    tier(2) { test_http('/', port: 8080, match: 'Apache Tomcat') }
    # the distribution itself runs, and the JVM is up under catalina
    tier(2) { test_local_command('tomcat version', '/opt/tomcat/bin/version.sh', 'Server version') }
    tier(2) { test_local_command('catalina process running', 'ps -eo user,args | grep [c]atalina', 'catalina') }
  end
end

TomcatTest.new.run
