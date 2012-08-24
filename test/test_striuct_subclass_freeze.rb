require_relative 'helper'

class TestStriuctFreeze < Test::Unit::TestCase

  Sth = Striuct.new :foo
  
  def test_freeze
    sth = Sth.new
    sth.freeze
    
    assert_raises RuntimeError do
     sth.foo = 8
    end
   
    assert_equal true, sth.frozen?
  end

end

