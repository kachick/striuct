require_relative 'helper'

class TestStriuctLock < Test::Unit::TestCase

  Sth = Striuct.new :foo, :bar
  Sth.__send__ :close
  
  def test_lock
    sth = Sth.new
    assert_equal false, sth.lock?(:foo)
    assert_equal false, sth.lock?(:bar)
    assert_equal false, sth.secure?
    sth.lock :bar
    assert_equal true, sth.lock?(:bar)
    assert_equal false, sth.secure?
  
    assert_raises RuntimeError do
     sth.bar = 1
    end
   
    sth.__send__ :unlock, :bar
    
    assert_equal false, sth.lock?(:bar)
    
    sth.bar = 1
    assert_equal 1, sth.bar
    
    sth.lock
    assert_equal true, sth.lock?(:foo)
    assert_equal true, sth.lock?(:bar)
    assert_equal true, sth.lock?
    
    assert_raises RuntimeError do
      sth.foo = 1
    end
    
    assert_equal true, sth.secure?
  end

end