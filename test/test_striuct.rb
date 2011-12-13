$VERBOSE = true
require File.dirname(__FILE__) + '/test_helper.rb'

class User < Striuct.new
  member :id, Integer
  member :last_name, /\A\w+\z/
  member :family_name, /\A\w+\z/
  member :address, /\A((\w+) ?)+\z/
  member(:age) {|v|(20..140).include? v}
end

class TestStriuct < Test::Unit::TestCase
  def test_builder
    klass = Striuct.new
    assert_kind_of Striuct, klass.new
    
    klass = Striuct.new :name, :age
    
    assert_equal klass.members, [:name, :age]
    
    klass = Striuct.new :foo do
      member :var
    end
    
    assert_equal klass.members, [:foo, :var]
    
    assert_equal User.members, [:id, :last_name, :family_name, :address, :age]
  end
  
  def test_setter
    user = User.new
    user[:last_name] = 'foo'
    assert_equal user.last_name, 'foo'
    user.last_name = 'bar'
    assert_equal user[:last_name], 'bar'
    
    assert_raises Striuct::ConditionError do
      user[:last_name] = 'foo s'
    end
  
    assert_raises Striuct::ConditionError do
      User.new 'asda'
    end
    
    assert_raises Striuct::ConditionError do
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

class TestStriuct2 < Test::Unit::TestCase
  def setup
    @user = User.new 9999, 'taro', 'yamada', 'Tokyo Japan', 30
  end

  def test_reader
    assert_equal @user[1], 'taro'
    assert_equal @user[:last_name], 'taro'
    assert_equal @user.last_name, 'taro'
  end

  def test_setter_pass
    assert_equal (@user.id = 2139203509295), 2139203509295
    assert_equal @user.id, 2139203509295
    assert_equal (@user.last_name = 'jiro'), 'jiro'
    assert_equal @user.last_name, 'jiro'
    assert_equal (@user.age = 40), 40
    assert_equal @user.age, 40
  end
  
  def test_setter_fail
    assert_raises Striuct::ConditionError do
      @user.id = 2139203509295.0
    end

    assert_raises Striuct::ConditionError do
      @user.last_name = 'ignore name'
    end
    
    assert_raises Striuct::ConditionError do
      @user.age = 19
    end
  end
  
  def test_strict?
    assert_equal @user.strict?, true
    @user.last_name.clear
    assert_equal @user.strict?, false
  end
end

class TestStriuct3 < Test::Unit::TestCase
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
  
  def test_each
    assert_same @user, @user.each{}
    assert_kind_of Enumerator, enum = @user.each
    assert_equal enum.next, 9999
    assert_equal enum.next, 'taro'
  end
  
  def test_each_member
    assert_same @user, @user.each_member{}
    assert_kind_of Enumerator, enum = @user.each_member
    assert_equal enum.next, :id
    assert_equal enum.next, :last_name
  end
  
  def test_values
    assert_equal @user.values, [9999, 'taro', 'yamada', 'Tokyo Japan', 30]
  end
  
  def test_values_at
    assert_equal @user.values_at(:age, :id), [30, 9999]
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
