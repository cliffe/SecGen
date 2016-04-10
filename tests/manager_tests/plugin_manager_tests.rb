require_relative '../../lib/managers/plugin_manager'
require_relative '../../lib/objects/wordpress/secure_plugin'
require_relative '../../lib/objects/wordpress/vulnerable_plugin'
require_relative '../../lib/constants'
require 'minitest/autorun'
require 'minitest/mock'


class PluginManagerTests < MiniTest::Test

  def setup
      @sut = PluginManager.new
  end


  def test_when_given_vulnerable_plugin_with_name_returns_correct_vulnerable_plugin
    #arrange
    vulnerable_plugin = VulnerablePlugin.new
    vulnerable_plugin.name = 'test1'

    vulnerable_plugins = []

    vulnerable_plugins << vulnerable_plugin

    valid_vulnerable_plugins = []

    (0..5).each { |i|
      valid_plugin = VulnerablePlugin.new
      valid_plugin.name = "test#{i}"
      valid_vulnerable_plugins << valid_plugin
    }

    #act
    result = @sut.process_vulnerable_plugins(vulnerable_plugins, valid_vulnerable_plugins)
    #assert
    assert_equal(result.count, 1, failure_message = "Returned #{result.count} plugins instead of 1 plugin.")
    assert(result.is_a?(Array))
    assert_equal(result[0].name, 'test1')
 end

  def test_when_given_secure_plugin_with_name_returns_correct_secure_plugin
   #arrange
   secure_plugin = SecurePlugin.new
   secure_plugin.name = 'test1'

   secure_plugins = []

   secure_plugins << secure_plugin

   valid_secure_plugins = []

   (0..5).each { |i|
     valid_plugin = SecurePlugin.new
     valid_plugin.name = "test#{i}"
     valid_secure_plugins << valid_plugin
   }

   #act
   result = @sut.process_secure_plugins(secure_plugins, valid_secure_plugins)
   #assert
   assert_equal(result.count, 1, failure_message = "Returned #{result.count} plugins instead of 1 plugin.")
   assert(result.is_a?(Array))
   assert_equal(result[0].name, 'test1')
 end

  def test_when_given_vulnerable_plugin_with_no_name_returns_random_vulnerable_plugin
   #arrange
   vulnerable_plugin = VulnerablePlugin.new
   vulnerable_plugin.name = ''

   vulnerable_plugins = []

   vulnerable_plugins << vulnerable_plugin

   valid_vulnerable_plugins = []

   (0..5).each { |i|
     valid_plugin = VulnerablePlugin.new
     valid_plugin.name = "test#{i}"
     valid_vulnerable_plugins << valid_plugin
   }

   #act
   result = @sut.process_vulnerable_plugins(vulnerable_plugins, valid_vulnerable_plugins)
   #assert
   assert_equal(result.count, 1, failure_message = "Returned #{result.count} plugins instead of 1 plugin.")
   assert(result.is_a?(Array))
 end

  def test_when_given_one_secure_plugin_with_no_name_returns_random_secure_plugin
   #arrange
   secure_plugin = SecurePlugin.new
   secure_plugin.name = ''

   secure_plugins = []

   secure_plugins << secure_plugin

   valid_secure_plugins = []

   (0..5).each { |i|
     valid_plugin = SecurePlugin.new
     valid_plugin.name = "test#{i}"
     valid_secure_plugins << valid_plugin
   }

   #act
   result = @sut.process_secure_plugins(secure_plugins, valid_secure_plugins)
   #assert
   assert_equal(result.count, 1, failure_message = "Returned #{result.count} plugins instead of 1 plugin.")
   assert(result.is_a?(Array))

 end

  def test_when_given_vulnerable_plugin_with_type_returns_a_vulnerable_plugin
   #arrange
   vulnerable_plugin = VulnerablePlugin.new
   vulnerable_plugin.vulnerability_type = 'test1'
   vulnerable_plugins = []
   vulnerable_plugins << vulnerable_plugin
   valid_vulnerable_plugins = []

   (0..5).each { |i|
     valid_plugin = VulnerablePlugin.new
     valid_plugin.vulnerability_type = "test#{i}"
     valid_vulnerable_plugins << valid_plugin
   }

   #act
   result = @sut.process_vulnerable_plugins(vulnerable_plugins, valid_vulnerable_plugins)
   print result
   #assert
   assert_equal(result.count, 1, failure_message = "Returned #{result.count} plugins instead of 1 plugin.")
   assert(result.is_a?(Array))
   assert_equal(result[0].vulnerability_type, 'test1')
 end

  def test_when_given_vulnerable_plugin_with_type_and_name_returns_a_vulnerable_plugin
    #arrange
    vulnerable_plugin = VulnerablePlugin.new
    vulnerable_plugin.vulnerability_type = 'test1'
    vulnerable_plugin.name = 'test1'

    vulnerable_plugins = []
    vulnerable_plugins << vulnerable_plugin
    valid_vulnerable_plugins = []

    (0..5).each { |i|
      valid_plugin = VulnerablePlugin.new
      valid_plugin.vulnerability_type = "test#{i}"
      valid_plugin.name = "test#{i}"
      valid_vulnerable_plugins << valid_plugin
    }

    #act
    result = @sut.process_vulnerable_plugins(vulnerable_plugins, valid_vulnerable_plugins)
    print result
    #assert
    assert_equal(result.count, 1, failure_message = "Returned #{result.count} plugins instead of 1 plugin.")
    assert(result.is_a?(Array))
    assert_equal(result[0].vulnerability_type, 'test1')
    assert_equal(result[0].name, 'test1')
  end


end