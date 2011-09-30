$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'configuration'

class ConfigurationTest < Test::Unit::TestCase
  
  def test_get_value
    Configuration.reset
    assert_equal 50, Configuration['pricing']['material']['carbon']
  end
  
  def test_environment
    
    Configuration.environment = 'test'
    Configuration.load_file( File.join( File.dirname(__FILE__), 'test_config.yaml' ) )
    
    assert_equal 'value', Configuration['key']
    assert_equal 'value2', Configuration['overwrite']

    Configuration.environment = 'prod'
    Configuration.load_file( File.join( File.dirname(__FILE__), 'test_config.yaml' ) )
    assert_equal 'me', Configuration['overwrite']
    
  end
  
end
