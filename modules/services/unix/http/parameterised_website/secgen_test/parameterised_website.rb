require_relative '../../../../../lib/post_provision_test'
require 'json'

class ParamWebsiteTest < PostProvisionTest
  DOCROOT = '/var/www/parameterised_website'

  def initialize
    self.module_name = 'parameterised_website'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    inputs = self.json_inputs

    tier(1) do
      test_local_command('apache2 installed', 'dpkg -l apache2 | grep -E "^ii"', 'apache2')
      test_local_command('index.html deployed', "test -s #{DOCROOT}/index.html && echo ok", 'ok')
      # the vhost listens on the configured port
      test_local_command('vhost uses the configured port',
                         "grep -rhE 'VirtualHost' /etc/apache2/sites-enabled/ /etc/apache2/sites-available/", ":#{self.port}>") if self.port.to_i > 0
    end
    tier(1) do
      # bundled bootstrap/js assets and the generated default stylesheet
      %w[css/bootstrap.min.css css/bootstrap-theme.min.css css/default.css js/bootstrap.min.js js/default.js js/jquery-1.12.4.js js/jquery-ui.js].each do |asset|
        test_local_command("#{asset} deployed", "test -s #{DOCROOT}/#{asset} && echo ok", 'ok')
      end
      # the distribution default site is removed (Tidy resource)
      test_local_command('default site removed', 'test ! -e /etc/apache2/sites-enabled/000-default.conf && echo gone', 'gone')
      test_local_command('apache2 running', 'systemctl is-active apache2 | grep -x active', 'active')
    end
    tier(2) do
      test_service_up
      test_http('/index.html', match: '<html')
      test_http('/css/bootstrap.min.css')
      test_http('/js/bootstrap.min.js')
      test_http('/css/default.css')
    end

    test_theme(inputs)
    test_org_functionality(inputs)
    test_strings_to_leak(inputs)
    test_main_page_paragraphs(inputs)
    test_white_text(inputs)
    test_images(inputs)
    test_tabs(inputs)
    test_additional_pages(inputs)
    test_security_audit_remit(inputs)
    test_acceptable_use_policy(inputs)
    # Nothing to observe for images_mode beyond the file mode checked in
    # test_images; no other inputs are skipped.
  end

  def present?(value)
    !value.nil? && value != ''
  end

  def organisation(inputs)
    raw = inputs['organisation']&.first
    return nil unless present?(raw)
    JSON.parse(raw)
  end

  def acceptable_use_policy?(inputs)
    inputs['host_acceptable_use_policy']&.first == 'true'
  end

  def test_theme(inputs)
    (inputs['theme'] || []).each do |theme|
      next unless present?(theme)
      # the chosen Bootswatch theme is on disk, served, and linked from the pages
      tier(1) { test_local_command("theme #{theme} deployed", "test -s #{DOCROOT}/css/#{theme} && echo ok", 'ok') }
      tier(2) do
        test_html_returned_content("/css/#{theme}", 'Bootswatch v4.0.0')
        test_html_returned_content('/index.html', "css/#{theme}")
      end
    end
  end

  def test_org_functionality(inputs)
    org = organisation(inputs)
    return unless org

    tier(2) do
      test_html_returned_content('/index.html', org['business_name']) if present?(org['business_name'])
      test_html_returned_content('/contact.html', org['business_motto']) if present?(org['business_motto'])
      %w[business_address office_telephone office_email].each do |field|
        test_html_returned_content('/contact.html', org[field]) if present?(org[field])
      end
      manager = org['manager']
      if manager.is_a?(Hash)
        %w[name phone_number email_address].each do |field|
          test_html_returned_content('/contact.html', manager[field]) if present?(manager[field])
        end
      end
      (org['employees'] || []).each do |employee|
        %w[name phone_number email_address].each do |field|
          test_html_returned_content('/contact.html', employee[field]) if present?(employee[field])
        end
      end
    end
  end

  # Leaked strings are HTML comments in the standard index page; the intranet
  # index (acceptable use policy enabled) does not include them.
  def test_strings_to_leak(inputs)
    return if acceptable_use_policy?(inputs)
    (inputs['strings_to_leak'] || []).each do |string|
      next unless present?(string)
      tier(2) { test_html_returned_content('/index.html', "<!-- #{string} -->", true) }
    end
  end

  # The paragraph(s) are on the standard index page only. An organisation's
  # intro_paragraph takes precedence over the main_page_paragraph_content input.
  def test_main_page_paragraphs(inputs)
    return if acceptable_use_policy?(inputs) || inputs['security_audit']
    org = organisation(inputs)
    intro = org ? Array(org['intro_paragraph']).reject { |p| !present?(p) } : []
    paragraphs = intro.empty? ? (inputs['main_page_paragraph_content'] || []) : intro
    paragraphs.each do |paragraph|
      next unless present?(paragraph)
      tier(2) { test_html_returned_content('/index.html', paragraph, true) }
    end
  end

  def test_white_text(inputs)
    return unless inputs['white_text']
    tier(2) do
      test_html_returned_content('/index.html', %(<div id="white_text">#{inputs['white_text'].join}</div>), true)
      test_html_returned_content('/css/default.css', '#white_text')
    end
  end

  # Images are written as image<N>.png (N from 1) in the docroot.
  def test_images(inputs)
    images = inputs['images_to_leak'] || []
    mode = inputs['images_mode']&.first
    images.each_with_index do |image, i|
      next unless present?(image)
      file = "#{DOCROOT}/image#{i + 1}.png"
      tier(1) do
        test_local_command("image#{i + 1}.png leaked", "test -s #{file} && echo ok", 'ok')
        if present?(mode) && mode =~ /\A[0-7]+\z/
          test_local_command("image#{i + 1}.png mode", "stat -c %a #{file}", mode.to_i(8).to_s(8))
        end
      end
      tier(2) do
        test_html_returned_content('/index.html', %(src="image#{i + 1}.png"), true)
        # Apache must be able to read the image, unless images_mode makes it
        # deliberately unreadable by others.
        world_readable = !(present?(mode) && mode =~ /\A[0-7]+\z/) || (mode.to_i(8) & 4) != 0
        test_http("/image#{i + 1}.png") if world_readable
      end
    end
  end

  # visible_tabs[0] is inline on the index page; later visible tabs, then the
  # hidden tabs, are separate tab_<n>.html files (hidden numbering follows on
  # from the visible tabs; hidden tab 0 is tab_0.html).
  def test_tabs(inputs)
    visible = inputs['visible_tabs'] || []
    hidden = inputs['hidden_tabs'] || []
    if present?(visible[0])
      tier(2) { test_html_returned_content('/index.html', visible[0], true) }
    end
    visible.each_with_index do |content, n|
      next if n == 0 || !present?(content)
      tier(2) { test_html_returned_content("/tab_#{n}.html", content, true) }
    end
    hidden.each_with_index do |content, counter|
      next unless present?(content)
      n = counter == 0 ? 0 : counter + visible.length - 1
      tier(2) { test_html_returned_content("/tab_#{n}.html", content, true) }
    end
  end

  def test_additional_pages(inputs)
    pages = inputs['additional_pages']
    names = inputs['additional_page_filenames']
    return unless pages && names
    pages.zip(names).each do |content, name|
      next unless present?(content) && present?(name)
      name = "/#{name}" unless name.start_with?('/')
      tier(1) { test_local_command("#{name} deployed", "test -s #{DOCROOT}#{name} && echo ok", 'ok') }
      tier(2) { test_html_returned_content(name, content, true) }
    end
  end

  def test_security_audit_remit(inputs)
    audit = inputs['security_audit']&.first
    return unless present?(audit)
    org = organisation(inputs)
    tier(2) do
      test_html_returned_content('/security_audit_remit.html', audit, true)
      if org && present?(org['business_name'])
        test_html_returned_content('/security_audit_remit.html', "Security Audit Remit of #{org['business_name']}")
      end
      test_html_returned_content('/index.html', 'security_audit_remit.html')
    end
  end

  def test_acceptable_use_policy(inputs)
    return unless acceptable_use_policy?(inputs)
    org = organisation(inputs)
    tier(2) do
      test_html_returned_content('/acceptable_use_policy.html', 'Acceptable Use Policy')
      test_html_returned_content('/acceptable_use_policy.html', org['business_name']) if org && present?(org['business_name'])
      test_html_returned_content('/index.html', 'acceptable_use_policy.html')
    end
  end

end

ParamWebsiteTest.new.run
