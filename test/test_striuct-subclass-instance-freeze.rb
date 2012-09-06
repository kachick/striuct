require_relative 'helper'

class Test_Striuct_Subclass_Instance__Freeze < Test::Unit::TestCase

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

