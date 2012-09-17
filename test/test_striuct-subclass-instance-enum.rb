require_relative 'helper'


class Test_Striuct_Subclass_Instance_Enum < Test::Unit::TestCase

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
  
  def test_each
    assert_same @user, @user.each{}
    assert_kind_of Enumerator, enum = @user.each
    assert_equal enum.next, 9999
    assert_equal enum.next, 'taro'
  end
  
  def test_each_member
    assert_same @user, @user.each_member{}
    assert_kind_of Enumerator, enum = @user.each_member
    assert_equal :id, enum.next
    assert_equal :last_name, enum.next
    assert_equal :family_name, enum.next
    assert_equal :address, enum.next
    assert_equal :age, enum.next
    assert_raises StopIteration do
      enum.next
    end
  end
  
  def test_each_index
    assert_same @user, @user.each_index{}
    assert_kind_of Enumerator, enum = @user.each_index
    assert_equal 0, enum.next
    assert_equal 1, enum.next
    assert_equal 2, enum.next
    assert_equal 3, enum.next
    assert_equal 4, enum.next
    assert_raises StopIteration do
      enum.next
    end
  end
  
  def test_each_with_index
    assert_same @user, @user.each_with_index{}
    assert_kind_of Enumerator, @user.each_with_index
    
    r = []
    @user.each_with_index do |value, index|
      r << [value, index]
    end
    
    assert_equal [@user.each_value.to_a, @user.each_index.to_a].transpose, r
  end

  def test_each_member_with_index
    assert_same @user, @user.each_member_with_index{}
    assert_kind_of Enumerator, @user.each_member_with_index
    
    r = []
    @user.each_member_with_index do |name, index|
      r << [name, index]
    end
    
    assert_equal [@user.each_member.to_a, @user.each_index.to_a].transpose, r
  end
  
  Sth = Striuct.define do
    member :name
    member :age
  end
  
  def test_each_pair_with_index
    sth = Sth.new 'a', 10
    assert_same sth, sth.each_pair_with_index{}
    
    enum = sth.each_pair_with_index    
    assert_equal [:name, 'a', 0], enum.next
    assert_equal [:age, 10, 1], enum.next
    assert_raises StopIteration do
      enum.next
    end
  end

end
