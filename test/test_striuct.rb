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
    
    assert_raises RuntimeError do
      user.age = 1
    end
    
    user = User2.define{|r|r.age = 1; r.name = ''}
    assert_same 1, user.age
    assert_same true, user.frozen?
    
    assert_raises RuntimeError do
      User2.define{|r|r.age = 1}
    end
    
    user = User2.define(false){|r|r.age = 1}
    assert_same 1, user.age
    
    user = User2.define(false, false){|r|r.age = 1}
    assert_same false, user.frozen?
  end
  
  def test_sufficient?
    assert_equal false, User.sufficient?(:age, 19)
    assert_equal true, User.sufficient?(:age, 20)
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
    assert_same @user.sufficient?(:last_name), true
    assert_same @user.strict?, true
    assert_same @user.sufficient?(:last_name), true
    @user.last_name.clear
    assert_same @user.sufficient?(:last_name), false
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
end


class TestStriuctSubclassInstance4 < Test::Unit::TestCase
  class Sth < Striuct.new
    member :bool, true, false
    member :sth
    protect_level :struct
    member :lambda, ->v{v % 3 == 2}, ->v{v.kind_of? Float}
  end
  
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
  class Sth < Striuct.new
    member :sth
  end
  
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
    assert_equal true, sth.default?(:lank)
    sth.lank = 2
    assert_equal false, sth.default?(:lank)
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
    
    assert_equal false, Sth.closed?
    
    Sth.__send__ :close
    
    assert_equal true, Sth.closed?
   
    assert_raises RuntimeError do
      Sth.class_eval do
        member :var2
      end
    end
   
    assert_equal false, sth.member?(:var2)
  end
end

class TestStriuctDefine < Test::Unit::TestCase
  def test_define
    assert_raises RuntimeError do
      Striuct.define do
      end
    end
    
    klass = Striuct.define do
      member :foo
    end

    assert_equal true, klass.closed?
  end
end

class TestStriuctFreeze < Test::Unit::TestCase
  Sth = Striuct.new :foo
  
  def test_freeze
    sth = Sth.new
    sth.freeze
    
    assert_raises RuntimeError do
     sth.foo = 8
    end
   
    assert_equal true, sth.frozen?
  end
end


class TestStriuctSafetyNaming < Test::Unit::TestCase
  def test_cname?
    klass = Striuct.new
    assert_same false, klass.cname?(Object)
    assert_same false, klass.cname?('m?')
    assert_same false, klass.cname?('__foo__')
    assert_same false, klass.cname?('a b')
    assert_same false, klass.cname?('object_id')
    assert_same true, klass.cname?('foo')
    klass.__send__ :protect_level, :warning
    assert_same false, klass.cname?('m?')
    assert_same false, klass.cname?('__foo__')
    assert_same false, klass.cname?('a b')
    assert_same false, klass.cname?('object_id')
    assert_same true, klass.cname?('foo')
    klass.__send__ :protect_level, :struct
    assert_same true, klass.cname?('m?')
    assert_same true, klass.cname?('__foo__')
    assert_same true, klass.cname?('a b')
    assert_same true, klass.cname?('object_id')
    assert_same true, klass.cname?('foo')
  end
  
  def test_protect
    klass = Striuct.new
    assert_raises NameError do
      klass.class_eval do
        member ''
      end
    end
    
    assert_raises NameError do
      klass.class_eval do
        member :'a b'
      end
    end

    assert_raises NameError do
      klass.class_eval do
        member :'__send__'
      end
    end

    assert_raises NameError do
      klass.class_eval do
        member :'__foo__'
      end
    end
    
    assert_raises NameError do
      klass.class_eval do
        member :'m?'
      end
    end
  
    assert_same false, klass.member?('m?')
    
    klass.class_eval do
      protect_level :struct
      member :'m?'
    end
    
    assert_same true, klass.member?('m?')
  end
end

class TestStriuctInference < Test::Unit::TestCase
  def test_inference
    klass = Striuct.define do
      member :n, Numeric, inference
      member :m, inference
    end
    
    sth, sth2 = klass.new, klass.new
    
    assert_raises Striuct::ConditionError do
      sth.n = '1'
    end
    
    sth.n = 1.1
    
    assert_equal 1.1, sth.n
    
    assert_raises Striuct::ConditionError do
      sth.n = 1
    end
    
    assert_raises Striuct::ConditionError do
      sth2.n = 1
    end
    
    sth.n = 2.1
    
    assert_equal 2.1, sth.n
    
    
    sth2.m = 1
    
    assert_equal 1, sth2.m
    
    assert_raises Striuct::ConditionError do
      sth.m = 1.0
    end
    
    assert_raises Striuct::ConditionError do
      sth2.m = 1.0
    end
    
    sth.m = 2
    
    assert_equal 2, sth.m
  end
end

class TestStriuctLoadPairs < Test::Unit::TestCase
  Sth = Striuct.new :foo, :bar, :hoge
  
  def test_load_pairs
    sth = Sth[hoge: 7, foo: 8]
   
    assert_equal [8, nil, 7], sth.values
  end
end

class TestStriuctObject < Test::Unit::TestCase
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

class TestStriuctHashLike < Test::Unit::TestCase
  Sth = Striuct.new :foo, :bar, :hoge

  def test_empty?
    sth = Sth[hoge: 7, foo: 8]
    assert_equal false, sth.empty?
    sth.each_member{|name|sth[name] = nil}
    assert_equal false, sth.empty?
    sth.each_member{|name|sth.unassign name}
    assert_equal true, sth.empty?
  end
  
  def test_has_value?
    sth = Sth[hoge: 7, foo: 8]
    assert_equal true, sth.value?(7)
    assert_equal true, sth.value?(8)
    assert_equal false, sth.value?(9)
    assert_equal false, sth.value?(nil)
  end
  
  def test_select!
    sth = Sth[hoge: 7, foo: 8]
    sth2, sth3 = sth.dup, sth.dup
  
    assert_kind_of Enumerator, enum = sth.select!
    assert_equal [:foo, 8], enum.next
    assert_equal [:bar, nil], enum.next
    assert_equal [:hoge, 7], enum.next
    assert_raises StopIteration do
      enum.next
    end

    assert_equal nil, sth2.select!{|k, v|true}
    assert_equal sth3, sth3.select!{|k, v|k == :hoge && v == 7}
    assert_equal nil, sth3.foo
    assert_equal true, sth3.assign?(:hoge)
    assert_equal false, sth3.assign?(:foo)
    assert_equal 7, sth3.hoge    
  end

  def test_keep_if
    sth = Sth[hoge: 7, foo: 8]
    sth2, sth3 = sth.dup, sth.dup
    
    assert_kind_of Enumerator, enum = sth.keep_if
    assert_equal [:foo, 8], enum.next
    assert_equal [:bar, nil], enum.next
    assert_equal [:hoge, 7], enum.next
    assert_raises StopIteration do
      enum.next
    end
    
    assert_equal sth2, sth2.keep_if{|k, v|true}
    assert_equal sth3, sth3.keep_if{|k, v|k == :hoge && v == 7}
    assert_equal nil, sth3.foo
    assert_equal true, sth3.assign?(:hoge)
    assert_equal false, sth3.assign?(:foo)
    assert_equal 7, sth3.hoge
  end
  
  def test_reject!
    sth = Sth[hoge: 7, foo: 8]
    sth2, sth3 = sth.dup, sth.dup
    
    assert_kind_of Enumerator, enum = sth.reject!
    assert_equal [:foo, 8], enum.next
    assert_equal [:bar, nil], enum.next
    assert_equal [:hoge, 7], enum.next
    assert_raises StopIteration do
      enum.next
    end
    
    enum.rewind
    assert_equal [:foo, 8], enum.next

    assert_equal nil, sth2.reject!{|k, v|false}
    assert_equal sth3, sth3.reject!{|k, v|k == :hoge && v == 7}
    assert_equal nil, sth3.hoge
    assert_equal false, sth3.assign?(:hoge)
    assert_equal true, sth3.assign?(:foo)
    assert_equal 8, sth3.foo
  end

  def test_delete_if
    sth = Sth[hoge: 7, foo: 8]
    sth2, sth3 = sth.dup, sth.dup
    
    assert_kind_of Enumerator, enum = sth.delete_if

    assert_equal [:foo, 8], enum.next
    assert_equal [:bar, nil], enum.next
    assert_equal [:hoge, 7], enum.next
    assert_raises StopIteration do
      enum.next
    end

    assert_equal sth2, sth2.delete_if{|k, v|false}
    assert_equal sth3, sth3.delete_if{|k, v|k == :hoge && v == 7}
    assert_equal nil, sth3.hoge
    assert_equal false, sth3.assign?(:hoge)
    assert_equal true, sth3.assign?(:foo)
    assert_equal 8, sth3.foo
  end
  
  def test_assoc
    sth = Sth[hoge: 7, foo: 8]

    assert_equal [:foo, 8], sth.assoc(:foo)
    assert_equal [:bar, nil], sth.assoc(:bar)
    assert_equal [:hoge, 7], sth.assoc(:hoge)
    
    assert_raises NameError do
      sth.assoc(:dummy)
    end
  end

  def test_rassoc
    sth = Sth[hoge: 7, foo: 7]

    assert_equal [:foo, 7], sth.rassoc(7)
    assert_equal [:bar, nil], sth.rassoc(nil)
    assert_equal nil, sth.rassoc(9)
  end

  def test_flatten
    sth = Sth[hoge: 7, foo: 8, bar: [1, 2]]
    assert_equal [:foo, 8, :bar, [1, 2], :hoge, 7], sth.flatten
    assert_equal [:foo, 8, :bar, [1, 2], :hoge, 7], sth.flatten(1)
    assert_equal [:foo, 8, :bar, 1, 2, :hoge, 7], sth.flatten(2)
    assert_equal [:foo, 8, :bar, 1, 2, :hoge, 7], sth.flatten(3)
    assert_equal [:foo, 8, :bar, 1, 2, :hoge, 7], sth.flatten(-1)
  end
end
