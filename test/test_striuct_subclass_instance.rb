require_relative 'helper'

class TestStriuctSubclassInstance1 < Test::Unit::TestCase
  class User < Striuct.new
    member :id, Integer
    member :last_name, /\A\w+\z/
    member :family_name, /\A\w+\z/
    member :address, /\A((\w+) ?)+\z/
    member :age, ->age{(20..140).include? age}
  end

  def test_setter
    user = User.new
    user[:last_name] = 'foo'
    assert_equal user.last_name, 'foo'
    user.last_name = 'bar'
    assert_equal user[:last_name], 'bar'
    
    assert_raises Validation::InvalidWritingError do
      user[:last_name] = 'foo s'
    end
  
    assert_raises Validation::InvalidWritingError do
      User.new 'asda'
    end
    
    assert_raises Validation::InvalidWritingError do
      user.age = 19
    end
  end
  
  def test_equal
    user1 = User.new 11218, 'taro'
    user2 = User.new 11218, 'taro'
    assert_equal true, (user1 == user2)
    user2.last_name = 'ichiro'
    assert_equal false, (user1 == user2)
  end
end

class TestStriuctSubclassInstance2 < Test::Unit::TestCase
  class User < Striuct.new
    member :id, Integer
    member :last_name, /\A\w+\z/
    member :family_name, /\A\w+\z/
    member :address, /\A((\w+) ?)+\z/
    member :age, ->age{(20..140).include? age}
  end
  
  def setup
    @user = User.new 9999, 'taro', 'yamada', 'Tokyo Japan', 30
  end

  def test_reader
    assert_equal @user[1], 'taro'
    assert_equal @user[:last_name], 'taro'
    assert_equal @user.last_name, 'taro'
  end

  def test_setter_pass
    assert_equal((@user.id = 2139203509295), 2139203509295)
    assert_equal @user.id, 2139203509295
    assert_equal((@user.last_name = 'jiro'), 'jiro')
    assert_equal @user.last_name, 'jiro'
    assert_equal((@user.age = 40), 40)
    assert_equal @user.age, 40
  end
  
  def test_setter_fail
    assert_raises Validation::InvalidWritingError do
      @user.id = 2139203509295.0
    end

    assert_raises Validation::InvalidWritingError do
      @user.last_name = 'ignore name'
    end
    
    assert_raises Validation::InvalidWritingError do
      @user.age = 19
    end
  end
  
  def test_strict?
    assert_same @user.sufficient?(:last_name), true
    assert_same @user.strict?, true
    assert_same @user.sufficient?(:last_name), true
    @user.last_name.clear
    assert_same @user.sufficient?(:last_name), false
    assert_same @user.strict?, false
  end
end

class TestStriuctSubclassInstance3 < Test::Unit::TestCase
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
    /\b(taro)\b/ =~ @user.to_s
    assert_equal 'taro', $1
  end

  def test_inspect
    /\b(taro)\b/ =~ @user.inspect
    assert_equal 'taro', $1
  end

  def test_members
    assert_equal @user.members, [:id, :last_name, :family_name, :address, :age]
  end
  
  def test_delegate_class_method
    assert_equal @user.members, User.members
    assert_equal @user.size, User.size
    assert_equal @user.member?(:age), User.member?(:age)
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
    
    assert_equal [@user.each_key.to_a, @user.each_index.to_a].transpose, r
  end

  def test_values
    assert_equal @user.values, [9999, 'taro', 'yamada', 'Tokyo Japan', 30]
  end
  
  def test_values_at
    assert_equal(@user.values_at(4, 0, (2..4)), [30, 9999, 'yamada', 'Tokyo Japan', 30])
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
end


class TestStriuctSubclassInstance4 < Test::Unit::TestCase
  class Sth < Striuct.new
    member :bool, OR(true, false)
    member :sth
    protect_level :struct
    member :lambda, OR(->v{v % 3 == 2}, ->v{v.kind_of? Float})
  end
  
  def setup
    @sth = Sth.new
  end

  def test_accessor
    @sth.bool = true
    assert_same true, @sth.bool
    @sth.bool = false
    assert_same false, @sth.bool
    
    assert_raises Validation::InvalidWritingError do
      @sth.bool = nil
    end
    
    @sth.sth = 1
    assert_same 1, @sth.sth

    @sth.sth = 'String'
    assert_equal 'String', @sth.sth
    
    @sth.sth = Class.class
    assert_same Class.class, @sth.sth
    
    assert_raises Validation::InvalidWritingError do
      @sth.lambda = 9
    end
    
    assert_raises Validation::InvalidWritingError do
      @sth.lambda = 7
    end
    
    @sth.lambda = 8
    assert_same 8, @sth.lambda

    @sth.lambda = 9.0
    assert_equal 9.0, @sth.lambda
  end
end

class TestStriuctHashKeyable < Test::Unit::TestCase

  Sth = Striuct.new :foo, :bar, :hoge

  def test_hash
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

class TestStriuctEachPair < Test::Unit::TestCase

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