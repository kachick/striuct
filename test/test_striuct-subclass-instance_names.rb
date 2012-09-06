require_relative 'helper'

class Test_Striuct_Subclass_Instance_Names < Test::Unit::TestCase

  class User < Striuct.new
    member :id, Integer
    member :last_name, /\A\w+\z/
    member :family_name, /\A\w+\z/
    member :address, /\A((\w+) ?)+\z/
    member :age, ->age{(20..140).include? age}
  end

  def test_members
    user = User.new 9999, 'taro', 'yamada', 'Tokyo Japan', 30
    assert_equal user.members, [:id, :last_name, :family_name, :address, :age]
  end

end
