$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'configuration'

class ConfigurationTest < Test::Unit::TestCase
  
  def test_get_value
    assert_equal 50, Configuration['pricing']['material']['carbon']
  end
  
end
