$VERBOSE = true
require File.dirname(__FILE__) + '/test_helper.rb'

class User < Striuct.new
  member :id, Integer
  member :last_name, /\A\w+\z/
  member :family_name, /\A\w+\z/
  member :address, /\A((\w+) ?)+\z/
  member :age, ->age{(20..140).include? age}
end


class TestStriuctSubclassEigen < Test::Unit::TestCase
  User2 = Striuct.new :name, :age
  
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

  def test_define
    user = User2.define{|r|r.age = 1; r.name = ''}
    assert_same 1, user.age
    
    assert_raises Striuct::LockError do
      user.age = 1
    end
    
    user = User2.define(false){|r|r.age = 1; r.name = ''}
    assert_same 1, user.age
    
    assert_raises RuntimeError do
      User2.define{|r|r.age = 1}
    end
  end
  
  def test_sufficent?
    assert_equal false, User.sufficent?(:age, 19)
    assert_equal true, User.sufficent?(:age, 20)
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

class TestStriuctSubclassInstance1 < Test::Unit::TestCase
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

class TestStriuctSubclassInstance2 < Test::Unit::TestCase
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
    assert_same @user.sufficent?(:last_name), true
    assert_same @user.strict?, true
    assert_same @user.sufficent?(:last_name), true
    @user.last_name.clear
    assert_same @user.sufficent?(:last_name), false
    assert_same @user.strict?, false
  end
end

class TestStriuctSubclassInstance3 < Test::Unit::TestCase
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
    assert_equal enum.next, :id
    assert_equal enum.next, :last_name
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
  
  def test_lock
    assert_same @user.lock?, false
    assert_same @user.secure?, false
    assert_same @user.lock, @user
    assert_same @user.lock?, true
    assert_same @user.secure?, false

    assert_raises Striuct::LockError do
      @user.id = 100
    end
    
    User.lock
    
    assert_same @user.secure?, true
    
    User.__send__ :unlock
    
    assert_equal @user.id, 9999
    assert_same (@user.__send__ :unlock), @user
    assert_same @user.lock?, false
    @user.id = 100
    assert_equal @user.id, 100
  end
end

class Sth < Striuct.new
  member :bool, true, false
  member :sth
  member :lambda, ->v{v % 3 == 2}, ->v{v.kind_of? Float}
end


class TestStriuctSubclassInstance4 < Test::Unit::TestCase
  def setup
    @sth = Sth.new
  end
  

  
  def test_accessor
    @sth.bool = true
    assert_same true, @sth.bool
    @sth.bool = false
    assert_same false, @sth.bool
    
    assert_raises Striuct::ConditionError do
      @sth.bool = nil
    end
    
    @sth.sth = 1
    assert_same 1, @sth.sth

    @sth.sth = 'String'
    assert_equal 'String', @sth.sth
    
    @sth.sth = Class.class
    assert_same Class.class, @sth.sth
    
    assert_raises Striuct::ConditionError do
      @sth.lambda = 9
    end
    
    assert_raises Striuct::ConditionError do
      @sth.lambda = 7
    end
    
    @sth.lambda = 8
    assert_same 8, @sth.lambda

    @sth.lambda = 9.0
    assert_equal 9.0, @sth.lambda
  end
end

class TestStriuctCloning < Test::Unit::TestCase
  def setup
    @sth = Sth.new
  end
  
  def test_clone
    sth2 = @sth.dup
    @sth.sth = 1
    assert_equal false, (@sth.sth == sth2.sth)
    
    sth2 = @sth.clone
    @sth.sth = 2
    assert_equal false, (@sth.sth == sth2.sth)
  end
  
  def test_class_clone
    klass = Sth.dup
    Sth.__send__ :member, :dummy1
    assert_equal false, klass.member?(:dummy)
    
    klass = Sth.clone
    Sth.__send__ :member, :dummy2
    assert_equal false, klass.member?(:dummy)
  end
end

class TestStriuctProcedure < Test::Unit::TestCase
  Sth = Striuct.new do
    member :age, /\A\d+\z/, Numeric do |arg|
      Integer arg
    end
  end
  
  def setup
    @sth = Sth.new
    assert_same nil, @sth.age
  end
  
  def test_procedure
    @sth.age = 10
    assert_same 10, @sth.age
    @sth.age = 10.0
    assert_same 10, @sth.age

    assert_raises Striuct::ConditionError do
      @sth.age = '10.0'
    end
    
    @sth.age = '10'
    assert_same 10, @sth.age
  end
end

class TestStriuctDefaultValue < Test::Unit::TestCase
  Sth = Striuct.new do
    member :lank, Integer
    default :lank, 1
  end
  
  def test_default
    sth = Sth.new 2
    assert_equal 2, sth.lank
    sth = Sth.new
    assert_equal 1, sth.lank
  end
  
  def test_define_default
    assert_raises NameError do
      Sth.class_eval do
        default :anything, 10
      end
    end
        
    assert_raises Striuct::ConditionError do
      Sth.class_eval do
        member :lank2, Integer
        default :lank2, '10'
      end
    end
  end
end

class TestStriuctFunctionalCondition < Test::Unit::TestCase
  Sthlambda = Striuct.new do
    member :lank, ->lank{lanks.include? lank}
    member :lanks
    default :lanks, 1..30
  end
  
  def test_lambda
    sth = Sthlambda.new
    sth.lank = 2
    assert_equal 2, sth.lank
    
    assert_raises Striuct::ConditionError do
      sth.lank = 31
    end
  end
  
  max = 9

  SthProc = Striuct.new do
    member :lank, Proc.new{|n|(3..max) === n}
  end

  def test_Proc
    sth = SthProc.new
    sth.lank = 8
    assert_equal 8, sth.lank
    
    assert_raises Striuct::ConditionError do
      sth.lank = 2
    end
  end
  
  SthMethod = Striuct.new do
    member :lank, 7.method(:<)
  end
  
  def test_Method
    sth = SthMethod.new
    sth.lank = 8
    assert_equal 8, sth.lank
    
    assert_raises Striuct::ConditionError do
      sth.lank = 6
    end
  end
end

class TestStriuctAssign < Test::Unit::TestCase
  Sth = Striuct.new do
    member :foo
  end  

  def test_unassign
    sth = Sth.new
    assert_equal false, sth.assign?(:foo)
    sth.foo = nil
    assert_equal true, sth.assign?(:foo)
    sth.unassign :foo
    assert_equal false, sth.assign?(:foo)
    
    assert_raises NameError do
      sth.unassign :var
    end
  end
end

class TestStriuctClassLock < Test::Unit::TestCase
  Sth = Striuct.new do
    member :foo
  end

  def test_class_lock
    sth = Sth.new

    assert_equal true, sth.member?(:foo)

    Sth.class_eval do
      member :bar
    end

    assert_equal true, sth.member?(:bar)
    assert_equal [:foo, :bar], sth.members

    Sth.lock
   
    assert_raises Striuct::LockError do
    Sth.class_eval do
      member :var2
     end
    end
   
    assert_equal false, sth.member?(:var2)
  end
end

class TestStriuctDefine < Test::Unit::TestCase
  def test_define
    klass = nil
    assert_raises RuntimeError do
     klass = Striuct.define do
     end
    end

    klass = Striuct.define do
     member :foo   
    end

    assert_equal true, klass.lock?
  end
end


