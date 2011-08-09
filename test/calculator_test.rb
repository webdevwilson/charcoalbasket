$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'calculator'

class CalculatorTest < Test::Unit::TestCase
  
  def test_common_sizes
    
    Configuration.reset
    
    i = Calculator.calculate('square:12x12x6')
    assert_equal 74.99, i[:carbon][:price]
    assert_equal 5.4, i[:carbon][:weight]
    assert_equal 12, i[:width]
    assert_equal 6, i[:height]
    
    assert_equal 145.99, i[:stainless][:price]
    assert_equal 6.15, i[:stainless][:weight]
    
    i = Calculator.calculate('round:18x6')
    assert_equal 88.99, i[:carbon][:price]
    assert_equal 4.59, i[:carbon][:weight]
    assert_equal 18, i[:width]
    assert_equal 6, i[:height]
    assert_equal 148.99, i[:stainless][:price]
    assert_equal 5.23, i[:stainless][:weight]
    
  end
  
  def test_calculations
    
    Configuration.load_file( File.join( File.dirname(__FILE__), 'test_config.yaml' ) )
    assert_equal 865.99, Calculator.calculate('square:12x12x6')[:carbon][:price]
    assert_equal 432, Calculator.calculate('square:12x12x6')[:carbon][:weight]
    
  end

end
