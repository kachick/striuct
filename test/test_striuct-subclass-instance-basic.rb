require_relative 'helper'

class Test_Striuct_Subclass_Instance_Basic < Test::Unit::TestCase

  class User < Striuct.new
    member :id, Integer
    member :last_name, /\A\w+\z/
    member :family_name, /\A\w+\z/
    member :address, /\A((\w+) ?)+\z/
    member :age, ->age{(20..140).include? age}
  end

  def setup
    @user = User.new 9999, 'taro', 'yamada', 'Tokyo Japan', 30
    @user2 = User.new 9999, 'taro', 'yamada', 'Tokyo Japan', 30
  end

  def test_members
    assert_equal @user.members, [:id, :last_name, :family_name, :address, :age]
  end
  
  def test_delegate_class_method
    assert_equal @user.members, User.members
    assert_equal @user.size, User.size
    assert_equal @user.member?(:age), User.member?(:age)
  end

  def test_values
    assert_equal @user.values, [9999, 'taro', 'yamada', 'Tokyo Japan', 30]
  end
  
  def test_values_at
    assert_equal(@user.values_at(4, 0, (2..4)), [30, 9999, 'yamada', 'Tokyo Japan', 30])
  end

end
