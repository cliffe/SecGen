require_relative '../../../../../lib/post_provision_test'

class CyberchefTest < PostProvisionTest
  # No inputs: the module copies the bundled CyberChef web app into /opt/cyberchef
  # (a static page opened locally; there is no web server or port).
  WEBAPP_DIR = '/opt/cyberchef'.freeze

  def initialize
    self.module_name = 'cyberchef'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('cyberchef directory exists', "test -d #{WEBAPP_DIR} && echo #{WEBAPP_DIR}", WEBAPP_DIR)
      test_local_command('CyberChef.html present', "test -f #{WEBAPP_DIR}/CyberChef.html && echo #{WEBAPP_DIR}/CyberChef.html", "#{WEBAPP_DIR}/CyberChef.html")
      # the rest of the bundle: versioned page, worker licences, assets and images
      test_local_command('versioned CyberChef page present', "ls #{WEBAPP_DIR}", 'CyberChef_v')
      test_local_command('worker licence files present', "ls #{WEBAPP_DIR}", 'ChefWorker.js.LICENSE.txt')
      test_local_command('assets directory present', "test -d #{WEBAPP_DIR}/assets && echo #{WEBAPP_DIR}/assets", "#{WEBAPP_DIR}/assets")
      test_local_command('images directory present', "test -d #{WEBAPP_DIR}/images && echo #{WEBAPP_DIR}/images", "#{WEBAPP_DIR}/images")
      test_local_command('runtime modules present', "ls #{WEBAPP_DIR}/modules", 'Bletchley.js')
      # files are mode 0744 as set in the manifest
      test_local_command('CyberChef.html mode 744', "stat -c '%a' #{WEBAPP_DIR}/CyberChef.html", '744')
    end
    tier(2) do
      # Files directory is world-readable (mode 0744)
      test_command_succeeds('CyberChef.html readable', "test -r #{WEBAPP_DIR}/CyberChef.html")
      test_command_succeeds('assets directory populated', "test -n \"$(ls #{WEBAPP_DIR}/assets)\"")
      test_local_command('CyberChef.html is the real app', "head -c 4000 #{WEBAPP_DIR}/CyberChef.html", 'CyberChef')
      # readable by an unprivileged account, as a student would open it
      test_command_succeeds('CyberChef.html readable by an unprivileged user', "head -c 100 #{WEBAPP_DIR}/CyberChef.html >/dev/null", user: 'nobody')
      # serve the app over HTTP on a throwaway local port and fetch it, as a browser would
      test_local_command('CyberChef served over HTTP',
                         "cd #{WEBAPP_DIR} && (python3 -m http.server 18734 --bind 127.0.0.1 >/dev/null 2>&1 & echo $! > /tmp/secgen-cyberchef.pid); sleep 2; " \
                         "python3 -c \"import urllib.request;print(urllib.request.urlopen('http://127.0.0.1:18734/CyberChef.html').read(4000).decode('utf-8','replace'))\"; " \
                         'kill $(cat /tmp/secgen-cyberchef.pid); rm -f /tmp/secgen-cyberchef.pid',
                         'CyberChef')
    end
  end
end

CyberchefTest.new.run
