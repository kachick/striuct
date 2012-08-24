require_relative 'helper'

class TestStriuctInference < Test::Unit::TestCase

  def test_inference
    klass = Striuct.define do
      member :n, Numeric, inference: true
      member :m, ANYTHING?, inference: true
    end
    
    sth, sth2 = klass.new, klass.new
    
    assert_raises Validation::InvalidWritingError do
      sth.n = '1'
    end
    
    sth.n = 1.1
    
    assert_equal 1.1, sth.n
    
    assert_raises Validation::InvalidWritingError do
      sth.n = 1
    end
    
    assert_raises Validation::InvalidWritingError do
      sth2.n = 1
    end
    
    sth.n = 2.1
    
    assert_equal 2.1, sth.n
    
    
    sth2.m = 1
    
    assert_equal 1, sth2.m
    
    assert_raises Validation::InvalidWritingError do
      sth.m = 1.0
    end
    
    assert_raises Validation::InvalidWritingError do
      sth2.m = 1.0
    end
    
    sth.m = 2
    
    assert_equal 2, sth.m
  end

end