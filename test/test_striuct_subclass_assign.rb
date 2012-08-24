require_relative 'helper'

class TestStriuctAssign < Test::Unit::TestCase

  Sth = Striuct.new do
    member :foo
  end  

  def test_unassign
    sth = Sth.new
    assert_equal false, sth.assign?(:foo)
    sth.foo = nil
    assert_equal true, sth.assign?(:foo)
    sth.unassign :foo
    assert_equal false, sth.assign?(:foo)
    sth.foo = nil
    assert_equal true, sth.assign?(:foo)
    sth.clear_at 0
    assert_equal false, sth.assign?(:foo)
    
    assert_raises NameError do
      sth.unassign :var
    end
    
    assert_raises IndexError do
      sth.unassign 1
    end
  end

end
