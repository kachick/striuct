require_relative 'helper'

class Test_Striuct_Subclass_Class_Freeze < Test::Unit::TestCase

  Sth = Striuct.new do
    member :foo
  end

  def test_class_freeze
    sth = Sth.new

    assert_same true, sth.member?(:foo)

    Sth.class_eval do
      member :bar
    end

    assert_same true, sth.member?(:bar)
    assert_equal [:foo, :bar], sth.members
    
    assert_same false, Sth.frozen?
    
    Sth.freeze
    
    assert_same true, Sth.frozen?
   
    assert_raises RuntimeError do
      Sth.class_eval do
        member :var2
      end
    end
   
    assert_same false, sth.member?(:var2)
  end

end
