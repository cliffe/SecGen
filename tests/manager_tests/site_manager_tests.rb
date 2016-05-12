require 'minitest/autorun'
require_relative '../../lib/managers/site_manager'
require_relative '../../lib/objects/wordpress/site'
require_relative '../../lib/constants'
class SiteManagerTests < MiniTest::Test
  def setup
    @sut = SiteManager.new
  end


  def test_theme_randomization_returns_random_theme_name
    result = @sut.get_random_theme_name
    assert_operator result.length, :>, 0
  end
end