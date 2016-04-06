require 'minitest/autorun'
require '../../lib/objects/system'

class WebEngineTests < MiniTest::Test

  def setup
    @sut = WebEngine.new
  end

  def test_when_given_system_with_single_site_should_match_wordpress_example
    #arrange
    @example = File.readlines('examples/wordpress_example.sh')
    @sites = Array.new
    @site_to_test = Site.new
    @site_to_test.name = 'wordpress'

    @sites.push(@site_to_test)
    @system = System.new(1, 'a system', 'a url', 'a basebox', Array.new, Array.new, Array.new, @sites)

    #act

    #assert

  end
end