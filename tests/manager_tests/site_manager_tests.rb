require 'minitest/autorun'
require '../../lib/managers/site_manager'
require '../../lib/objects/wordpress/site'
require '../../lib/objects/wordpress/plugin'
class SiteManagerTests < MiniTest::Test
  def setup
    @sut = SiteManager.new

  end

  def test_when_site_is_specified_should_produce_one_site
    #arange
    sites = []
    site = Site.new
    site.name = 'SiteName'
    site.plugins = []
    site.theme= 'SiteTheme'
    site.users = []
    site.admin_user = 'AdminUser'
    site.admin_password = 'AdminPassword'
    site.admin_email = 'AdminEmail'
    site.users << User.new('UserName', 'Password', 'Email')
    site.plugins << Plugin.new('PluginName', true, '1.2.3')

    sites << site
    #act
    result = @sut.process(site)
    #assert
    assert_equal(result.count, 1, failure_message='Manager produced more than one site')
    assert_equal(result[0].name, 'SiteName', failure_message='Manager produced site with different name')
    assert_equal(result[0].plugins.count, 1, failure_message='Manager produced more than one plugin')
    assert_equal(result[0].plugins[0], site.plugins[0] , failure_message='Manager produced different plugin')

  end

  def test_when_nothing_is_specified_should_randomize_one_site_from_metadata

  end
end