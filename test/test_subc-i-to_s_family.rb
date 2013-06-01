require_relative 'helper'

class Test_Striuct_Subclass_Instance_to_s_Family < Test::Unit::TestCase

  class User < Striuct.new
    member :id, Integer, must: true
    member :name, /\w+/
  end

  def setup
    @sth = User.new 9999, 'taro'
    @sth.lock(:name)
    @sth.name.clear
  end

  def test_to_s
    assert_equal %q!#<struct' Test_Striuct_Subclass_Instance_to_s_Family::User id=9999, name="">!,
                 @sth.to_s
  end

  def test_inspect
    assert_equal %q!#<struct' Test_Striuct_Subclass_Instance_to_s_Family::User id=9999(must), name=""(invalid, locked)>!,
                 @sth.inspect
  end

end
