require_relative 'helper'

class Test_Striuct_Subclass_Instance_to_s_Family < Test::Unit::TestCase

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
  
  def test_to_s
    assert_equal %q!#<struct' Test_Striuct_Subclass_Instance_to_s_Family::User id=9999, last_name="taro", family_name="yamada", address="Tokyo Japan", age=30>!, @user.to_s
  end

  def test_inspect
    assert_equal %q!#<struct' Test_Striuct_Subclass_Instance_to_s_Family::User strict?:true id=9999(valid?:true, lock?:false), last_name="taro"(valid?:true, lock?:false), family_name="yamada"(valid?:true, lock?:false), address="Tokyo Japan"(valid?:true, lock?:false), age=30(valid?:true, lock?:false)>!, @user.inspect
  end

end
