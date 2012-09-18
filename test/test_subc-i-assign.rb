require_relative 'helper'

class Test_Striuct_Subclass_Instance_Assign < Test::Unit::TestCase

  Sth = Striuct.new do
    member :foo
  end  

  [:unassign, :delete_at].each do |method|
    define_method :"test_#{method}" do
      sth = Sth.new
      assert_equal false, sth.assign?(:foo)
      sth.foo = nil
      assert_equal true, sth.assign?(:foo)
      sth.public_send method, :foo
      assert_equal false, sth.assign?(:foo)
      sth.foo = nil
      assert_equal true, sth.assign?(:foo)
      sth.public_send method, 0
      assert_equal false, sth.assign?(:foo)
      
      assert_raises NameError do
        sth.public_send method,  :var
      end
      
      assert_raises IndexError do
        sth.public_send method,  1
      end
    end
  end

end