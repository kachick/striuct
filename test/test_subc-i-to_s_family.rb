require_relative 'helper'

class Test_Striuct_Subclass_Instance_to_s_Family < Test::Unit::TestCase

  class User < Striuct.new
    member :id, Integer
    member :last_name, /\A\w+\z/
    member :family_name, /\A\w+\z/
    member :address, /\A((\w+) ?)+\z/
    member :age, ->age{(20..140).include? age}
  end

  def test_to_s
    user = User.new 9999, 'taro', 'yamada', 'Tokyo Japan', 30
    assert_equal %q!#<struct' Test_Striuct_Subclass_Instance_to_s_Family::User id=9999, last_name="taro", family_name="yamada", address="Tokyo Japan", age=30>!,
                 user.to_s
  end

  def test_inspect
    user = User.new 9999, 'taro', 'yamada', 'Tokyo Japan', 30
    assert_equal %q!#<struct' Test_Striuct_Subclass_Instance_to_s_Family::User strict?:true id=9999(valid?:true, locked?:false), last_name="taro"(valid?:true, locked?:false), family_name="yamada"(valid?:true, locked?:false), address="Tokyo Japan"(valid?:true, locked?:false), age=30(valid?:true, locked?:false)>!,
                 user.inspect
  end

end