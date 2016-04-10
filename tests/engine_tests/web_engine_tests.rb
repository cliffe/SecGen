require 'minitest/autorun'
require '../../lib/objects/site'
require '../../lib/helpers/site_processor'

class WebEngineTests < MiniTest::Test

  def setup
    @example = File.read('examples/wordpress_example_single_site.sh')
    @sites = Array.new
    @site_to_test = Site.new
    @site_to_test.name = 'wordpress'
    @site_to_test.plugins = Array.new
    @site_to_test.admin_user = 'root'
    @site_to_test.admin_password = 'pa55w0rd'
    @site_to_test.admin_email = 'test@test.net'

    @site_to_test.theme = 'Theme'
    @site_to_test.users = Array.new
    @sites.push(@site_to_test)
    @sut = SiteProcessor.new(@sites)
  end

  def test_when_given_system_with_single_site_should_match_wordpress_example_single_site

    #act
    result = @sut.generate_script
    #assert

    print result
    assert_equal(@example, result, failure_message = 'Result did not match example')

  end
end