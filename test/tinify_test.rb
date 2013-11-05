require File.dirname(__FILE__) + '/test_helper'

class ArrayTinifyTest < Test::Unit::TestCase
  def test_true
    a = [true]*10
    
#    puts "#{a.tinify}"
    assert_equal [[true, 10]], a.tinify
  end
  
  def test_true_false
    a = [[true]*10, [false]*10].flatten
    
    assert_equal [[true, 10], [false, 10]], a.tinify
  end
end
