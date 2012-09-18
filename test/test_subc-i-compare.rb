require_relative 'helper'


class Test_Striuct_Subclass_Instance_Compare < Test::Unit::TestCase
  
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
  
  def test_hash
    assert_kind_of Integer, @user.hash
    assert_equal @user.hash, @user2.hash
  end
  
  def test_eql?
    assert_equal true, @user.eql?(@user2)
    assert_equal true, @user2.eql?(@user)
    assert_equal false, @user.eql?(User.new 9999, 'taro', 'yamada', 'Tokyo Japan', 31)
  end
  
  def test_equal
    user1 = User.new 11218, 'taro'
    user2 = User.new 11218, 'taro'
    assert_equal true, (user1 == user2)
    user2.last_name = 'ichiro'
    assert_equal false, (user1 == user2)
  end
  
  Sth = Striuct.new :foo, :bar, :hoge

  def test_hashkeyable
    sth1 = Sth[hoge: 7, foo: 8]
    sth2 = Sth[hoge: 7, foo: 8]
    assert_equal true, sth1.eql?(sth2)
    assert_equal true, sth2.eql?(sth1)
    assert_equal sth1.hash, sth2.hash
    assert_equal true, {sth1 => 1}.has_key?(sth2)
    assert_equal true, {sth2 => 1}.has_key?(sth1)
    assert_equal 1, {sth1 => 1}[sth2]
    assert_equal 1, {sth2 => 1}[sth1]
  end
  
end