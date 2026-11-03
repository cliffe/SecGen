require_relative '../../../../../lib/post_provision_test'
require 'json'

class ParamWebsiteTest < PostProvisionTest
  attr_accessor :organisation

  def initialize
    self.module_name = 'vuln_parameterised_website'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    json_inputs = get_json_inputs
    test_service_up
    test_html_returned_content("/css/#{json_inputs['theme'][0]}", 'Bootswatch v4.0.0')
    test_org_functionality(json_inputs)
    test_additional_page(json_inputs)
    test_security_audit_remit(json_inputs)
    test_acceptable_use_policy(json_inputs)
    test_sqli_auth_bypass
  end

  # Tier 3 — SQL injection auth bypass, driven as an HTTP POST from the attacker
  # VM (the non-Metasploit HTTP-exploit path, Phase 1C). login_process.php
  # interpolates the username straight into the SQL string, so ' OR '1'='1'#
  # matches every row and logs in with no valid credentials. On success the app
  # issues a 302 to index.php (a failed login redirects to login.php instead),
  # which the helper detects in the response headers (include_headers). This is
  # the first consumer of test_http_exploit; with no attacker VM it SKIPs, so
  # the module test still works on its own.
  def test_sqli_auth_bypass
    sqli = "' OR '1'='1'#"
    test_http_exploit('/login_process.php',
                      method: 'POST',
                      data: "username=#{sqli}&password=x",
                      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
                      include_headers: true,
                      expect: %r{location:\s*index\.php}i,
                      label: 'SQLi auth bypass (login_process.php)',
                      tier: 3)
  end

  def get_organisation(json_inputs)
    JSON.parse(json_inputs['organisation'][0])
  end

  def test_org_functionality(json_inputs)
    if json_inputs['organisation'] and
        json_inputs['organisation'][0] and
        json_inputs['organisation'][0] != ''

      organisation = get_organisation(json_inputs)
      employee_1 = organisation['employees'][0]

      # the module renders these as PHP (install.pp: index.php, contact.php);
      # only the policy/audit pages below are served as .html
      test_html_returned_content('/index.php', organisation['business_name'])
      test_html_returned_content('/contact.php', organisation['business_motto'])
      test_html_returned_content('/contact.php', employee_1['name'])
    end
  end

  def test_security_audit_remit(json_inputs)
    if json_inputs['security_audit'] and
        json_inputs['security_audit'][0] and
        json_inputs['security_audit'][0] != ''
      test_html_returned_content('/security_audit_remit.html', "Security Audit Remit of #{get_organisation(json_inputs)['business_name']}")
    end
  end

  def test_acceptable_use_policy(json_inputs)
    if json_inputs['host_acceptable_use_policy'] and
        json_inputs['host_acceptable_use_policy'][0] and
        json_inputs['host_acceptable_use_policy'][0] == 'true'
      test_html_returned_content('/acceptable_use_policy.html', "Acceptable Use Policy")
      test_html_returned_content('/acceptable_use_policy.html', get_organisation(json_inputs)['business_name'])
    end
  end

  def test_additional_page(json_inputs)
    if json_inputs['additional_page_filenames'] and
        json_inputs['additional_page_filenames'][0] and
        json_inputs['additional_page_filenames'][0].include? 'html' and
        json_inputs['additional_pages'] and
        json_inputs['additional_pages'][0]

      page_name = json_inputs['additional_page_filenames'][0]
      page_name = "/#{page_name}" if page_name.split[0] != '/'

      test_html_returned_content(page_name, json_inputs['additional_pages'][0], true)
    end
  end

end

ParamWebsiteTest.new.run