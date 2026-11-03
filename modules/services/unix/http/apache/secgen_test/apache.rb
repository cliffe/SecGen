require_relative '../../../../../lib/post_provision_test'
require 'json'
require 'shellwords'

class ApacheTest < PostProvisionTest
  def initialize
    self.module_name = 'apache'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Inputs: domain (vhost ServerName), cert_bundle (HTTPS cert and key), uri and
  # strings_to_leak (leaked page at the uri's path) are all checked below.
  # HTTP is on port 80 and HTTPS on 443; neither is an input.
  def test_module
    super
    docroot = '/var/www/html'
    domain = self.json_inputs['domain']&.first
    uri = self.json_inputs['uri']&.first
    leak = self.json_inputs['strings_to_leak']&.first
    bundle_json = self.json_inputs['cert_bundle']&.first
    bundle = (bundle_json.nil? || bundle_json.strip.empty?) ? nil : (JSON.parse(bundle_json) rescue nil)

    # the module takes the third '/'-separated part of the uri, as the Puppet does
    leak_path = nil
    if uri && !uri.empty?
      normalised = uri.end_with?('/') ? uri : "#{uri}/"
      leak_path = normalised.split('/')[3]
    end
    leak_line = leak.to_s.lines.map(&:strip).reject(&:empty?).first

    tier(1) do
      test_local_command('apache2 installed?', 'dpkg -l apache2 | grep -E "^ii"', 'apache2')
      test_local_command('apache2 binary present', 'which apache2 apache2ctl', 'apache2')
      test_local_command('prefork MPM configured', 'apache2ctl -V', 'prefork')
      test_local_command('mod_ssl enabled', 'ls /etc/apache2/mods-enabled/', 'ssl.load')
      test_local_command('apache2 enabled at boot', 'systemctl is-enabled apache2', 'enabled')
      if domain
        test_local_command("vhost ServerName #{domain}", 'grep -Rh ServerName /etc/apache2/sites-enabled/', "ServerName #{domain}")
      end
      if bundle
        test_local_command('certificate installed', 'ls -l /etc/ssl/certs/secgen-apache.crt', 'secgen-apache.crt')
        test_local_command('private key installed mode 600', 'stat -c %a /etc/ssl/private/secgen-apache.key', '600')
        # the files on disk are the supplied bundle
        cert_first = bundle['cert_pem'].to_s.lines.map(&:strip).reject { |l| l.start_with?('-----') || l.empty? }.first
        test_local_command('certificate is the supplied cert', 'cat /etc/ssl/certs/secgen-apache.crt', cert_first) if cert_first
        test_local_command('certificate parses', 'openssl x509 -noout -subject -in /etc/ssl/certs/secgen-apache.crt', 'subject')
      end
      if leak_path && leak_line
        test_local_command("leaked page /#{leak_path}/index.html exists", "cat #{docroot}/#{leak_path.shellescape}/index.html", leak_line)
        test_local_command('leaked page owned by www-data', "stat -c %U #{docroot}/#{leak_path.shellescape}/index.html", 'www-data')
      end
    end

    tier(2) do
      test_service_up(port: 80)
      test_http('/', port: 80)
      test_local_command('apache config syntax', 'apache2ctl -t 2>&1', 'Syntax OK')
      test_local_command('apache workers run as www-data', 'ps -o user= -C apache2', 'www-data')
      # the vhost for the configured domain is live on port 80
      test_local_command("vhost #{domain} listed on port 80", 'apache2ctl -S', "port 80 namevhost #{domain}") if domain
      if bundle
        test_service_up(port: 443)
        test_http('/', port: 443, scheme: 'https')
        # the certificate served on 443 is the supplied one
        served = "bash -c 'diff <(openssl x509 -noout -fingerprint -in /etc/ssl/certs/secgen-apache.crt) " \
                 "<(echo | openssl s_client -connect 127.0.0.1:443 2>/dev/null | openssl x509 -noout -fingerprint) && echo same-cert'"
        test_local_command('port 443 serves the supplied certificate', served, 'same-cert')
      end
      if leak_path && leak_line
        test_http("/#{leak_path}/", match: leak_line, port: 80, label: "leaked page /#{leak_path}/ served")
      end
    end
  end
end

ApacheTest.new.run
