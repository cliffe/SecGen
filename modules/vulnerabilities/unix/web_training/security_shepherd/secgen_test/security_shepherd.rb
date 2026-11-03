require_relative '../../../../../lib/post_provision_test'
require 'shellwords'

class SecurityShepherdTest < PostProvisionTest
  CLASSES_DIR = '/var/lib/tomcat9/webapps/ROOT/WEB-INF/classes'

  def initialize
    self.module_name = 'security_shepherd'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('tomcat9 installed', 'dpkg -l tomcat9 | grep -E "^ii"', 'tomcat9')
      test_local_command('shepherd ROOT deployed', 'test -d /var/lib/tomcat9/webapps/ROOT/admin && echo ok', 'ok')
      # Its MariaDB settings are a conf.d drop-in; the mysql module's my.cnf
      # (with skip-ssl) must survive alongside it.
      test_local_command('shepherd MariaDB drop-in installed',
                         'grep -c "^bind-address=\*" /etc/mysql/conf.d/security_shepherd.cnf', '1')
      test_local_command('mysql module my.cnf kept (skip-ssl)', 'grep -c "^skip-ssl" /etc/mysql/my.cnf', '1')
    end

    # The module ships its own server.xml: Tomcat listens on 80 and 443 (the
    # stock 8080 connector is commented out), and web.xml marks the whole app
    # CONFIDENTIAL, so plain HTTP only redirects and the pages are served on 443.
    # There is no 'port' input, hence the literals.
    tier(2) do
      test_service_up(port: 80)
      test_service_up(port: 443)
      test_http('/login.jsp', port: 80, status: 302, label: 'HTTP :80 redirects to HTTPS')
      test_http('/login.jsp', port: 443, scheme: 'https', status: 200, match: 'Security Shepherd',
                label: 'HTTPS :443 login page')
    end

    # Inputs: modules and flag_store are written to files in the webapp's
    # classes directory; unix_username becomes a 'player' row in the rendered
    # core schema. All three are checked from json_inputs.
    tier(2) do
      (self.json_inputs['modules'] || []).each_with_index do |mod, i|
        next if mod.to_s.strip.empty?
        test_local_command("active-modules lists module #{i + 1}",
                           "grep -cxF -- #{Shellwords.escape(mod)} #{CLASSES_DIR}/active-modules", '1')
      end
      (self.json_inputs['flag_store'] || []).each_with_index do |flag, i|
        next if flag.to_s.strip.empty?
        test_local_command("flags file holds flag #{i + 1}",
                           "grep -cxF -- #{Shellwords.escape(flag)} #{CLASSES_DIR}/flags", '1')
      end
      if (user = self.json_inputs['unix_username']&.first)
        # Query the live core database: the rendered /tmp/coreSchema.sql is
        # removed at boot, so it is gone by the time the test runs. The root
        # password is the module's fixed lab value (mariadb.pp / grant.sql);
        # it is passed through MYSQL_PWD, not on the mysql command line.
        test_local_command('player account created for unix_username',
                           "MYSQL_PWD=CowSaysMoo mysql -u root -N -e " \
                           "\"select count(*) from core.users where userRole='player' and userName='#{user}'\"",
                           '1')
      end
    end
    # No tier 3: Security Shepherd is a training platform, not an exploitable service.
  end
end

SecurityShepherdTest.new.run
