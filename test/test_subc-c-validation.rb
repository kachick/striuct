require_relative 'helper'

class Test_Striuct_Subclass_Class_Validation < Test::Unit::TestCase

  class User < Striuct.new
    member :id, Integer
    member :last_name, /\A\w+\z/
    member :family_name, /\A\w+\z/
    member :address, /\A((\w+) ?)+\z/
    member :age, ->age{(20..140).include? age}
  end
  
  def test_restrict?
    klass = Striuct.new :foo do
      member :var, //
      member :hoge
      member :moge, nil
    end
    
    assert_equal false, klass.restrict?(:foo)
    assert_equal true, klass.restrict?(:var)
    assert_equal false, klass.restrict?(:hoge)
    assert_equal true, klass.restrict?(:moge)
  end

end  
