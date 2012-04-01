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
  User2 = Striuct.define do
    member :name, AND(String, NOT(''))
    member :age, Fixnum
  end
  
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
    user = User2.define{|r|r.age = 1; r.name = 'a'}
    assert_same 1, user.age
    
    assert_raises RuntimeError do
      user.age = 1
    end
    
    user = User2.define{|r|r.age = 1; r.name = 'a'}
    assert_same 1, user.age
    assert_same true, user.lock?
    assert_same false, user.frozen?
    
    assert_raises RuntimeError do
      User2.define{|r|r.age = 1}
    end
    
    user = User2.define(lock: true){|r|r.age = 1; r.name = 'a'}
    assert_same 1, user.age
    assert_same true, user.lock?
    user = User2.define(lock: false){|r|r.age = 1; r.name = 'a'}
    assert_same false, user.lock?
    assert_equal true, user.strict?
    
    assert_raises Striuct::ConditionError do
      User2.define{|r|r.age = 1; r.name = 'a'; r.name.clear}
    end
    
    user = User2.define(strict: false){|r|r.age = 1; r.name = 'a'; r.name.clear}
    assert_equal '', user.name
    assert_equal false, user.strict?
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
  
  def test_add_members
    klass = Striuct.new :foo do
      add_members :aaa, 'bbb', :ccc
    end
    
    assert_equal [:foo, :aaa, :bbb, :ccc], klass.members
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
    assert_kind_of Enumerator, enum = @user.each_with_index
    
    r = []
    @user.each_with_index do |value, index|
      r << [value, index]
    end
    
    assert_equal [@user.each_value.to_a, @user.each_index.to_a].transpose, r
  end

  def test_each_member_with_index
    assert_same @user, @user.each_member_with_index{}
    assert_kind_of Enumerator, enum = @user.each_member_with_index
    
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
  
  def test_class_dup
    klass = Sth.dup
    Sth.__send__ :member, :dummy1
    assert_equal false, klass.member?(:dummy1)
  end
  
  def test_class_clone
    klass = Sth.clone
    Sth.__send__ :member, :dummy2
    assert_equal false, klass.member?(:dummy2)
  end
end

class TestStriuctProcedure < Test::Unit::TestCase
  Sth = Striuct.new do
    member :age, Numeric, &->arg{Integer arg}
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
    member :lank, OR(Bignum, Fixnum)
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
    
    klass = Striuct.define do
      member :lank2, Integer
      default :lank2, '10'
    end

    assert_raises Striuct::ConditionError do
      klass.new
    end
    
    scope = self
    seef = nil
    klass = Striuct.define do
      member :lank, Integer
      scope.assert_raises ArgumentError do
        default :lank, '10', &->own, name{rand}
      end
      
      scope.assert_raises ArgumentError do
        default :lank, '10', &->own{rand}
      end
      
      scope.assert_raises ArgumentError do
        default :lank, '10', &->{rand}
      end
      
      default :lank, &->own, name{(seef = own); rand}
    end
    
    assert_raises Striuct::ConditionError do
      klass.new
    end
    
    klass = Striuct.define do
      member :lank, Integer      
      default :lank, &->own, name{(seef = own); 10 - name.length}
    end
    
    assert_equal 6, klass.new.lank
    assert_equal seef, klass.new
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
    sth.foo = nil
    assert_equal true, sth.assign?(:foo)
    sth.clear_at 0
    assert_equal false, sth.assign?(:foo)
    
    assert_raises NameError do
      sth.unassign :var
    end
    
    assert_raises IndexError do
      sth.unassign 1
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
    assert_same false, klass.cname?('to_ary')
    assert_same true, klass.cname?('foo')
    klass.__send__ :protect_level, :warning
    assert_same false, klass.cname?('m?')
    assert_same false, klass.cname?('__foo__')
    assert_same false, klass.cname?('a b')
    assert_same false, klass.cname?('object_id')
    assert_same false, klass.cname?('to_ary')
    assert_same true, klass.cname?('foo')
    klass.__send__ :protect_level, :struct
    assert_same true, klass.cname?('m?')
    assert_same true, klass.cname?('__foo__')
    assert_same true, klass.cname?('a b')
    assert_same true, klass.cname?('object_id')
    assert_same true, klass.cname?('to_ary')
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
      member :n, Numeric, inference: true
      member :m, anything, inference: true
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
  
  def test_select
    sth = Sth[hoge: 7, foo: 8]

    assert_kind_of Enumerator, enum = sth.select
    
    assert_equal Sth[hoge: 7], sth.select{|k, v|k == :hoge}
  end

  def test_reject
    sth = Sth[hoge: 7, foo: 8]

    assert_kind_of Enumerator, enum = sth.reject
    
    assert_equal Sth[foo: 8], sth.reject{|k, v|k == :hoge}
  end
end


class TestStriuctAliasMember < Test::Unit::TestCase
  class Sth < Striuct.new
    member :foo, String
    
    member :bar, Integer do |v|
      v
    end
    
    member :hoge, Symbol
    default :hoge, :'Z'
    alias_member :abc, :bar
    default :abc, 8
  end

  def test_alias_member
    sth = Sth.new 'A'
    assert_equal [:foo, :bar, :hoge], sth.members

    assert_equal 8, sth[:abc]
    flavor = Sth.__send__(:flavor_for, :abc)
    assert_kind_of Proc, flavor
    assert_same flavor, Sth.__send__(:flavor_for, :bar)
    assert_equal 8, sth.abc
    sth.abc = 5
    assert_equal 5, sth.bar
    sth[:abc] = 6
    assert_equal 6, sth.bar
    
    assert_raises Striuct::ConditionError do
      sth[:abc] = 'a'
    end
    
    assert_raises Striuct::ConditionError do
      sth.abc = 'a'
    end
    
    assert_raises Striuct::ConditionError do
      sth.bar = 'a'
    end
    
    assert_raises ArgumentError do
      Sth.class_eval do
        member :abc
      end
    end
  end
end

class TestStriuctSpecificConditions < Test::Unit::TestCase
  Sth = Striuct.define do
    member :list_only_int, GENERICS(Integer)
    member :true_or_false, boolean
    member :like_str, stringable
    member :has_x, CAN(:x)
    member :has_x_and_y, CAN(:x, :y)
    member :one_of_member, MEMBER_OF([1, 3])
    member :has_ignore, AND(1..5, 3..10)
    member :nand, NAND(1..5, 3..10)
    member :all_pass, OR(1..5, 3..10)
    member :catch_name_error, CATCH(NameError){|v|v.no_name!}
    member :no_exception, STILL(->v{v.class})
    member :not_integer, NOT(Integer)
  end

  def test_not
    sth = Sth.new
    
    obj = Object.new
    
    sth.not_integer = obj
    assert_same obj, sth.not_integer

    assert_raises Striuct::ConditionError do
      sth.not_integer = 1
    end
  end


  def test_still
    sth = Sth.new
    
    obj = Object.new
    
    sth.no_exception = obj
    assert_same obj, sth.no_exception
    sth.no_exception = false

    obj.singleton_class.class_eval do
      undef_method :class
    end

    assert_raises Striuct::ConditionError do
      sth.no_exception = obj
    end
  end

  def test_catch
    sth = Sth.new
    
    obj = Object.new
    
    sth.catch_name_error = obj
    assert_same obj, sth.catch_name_error
    sth.catch_name_error = false

    obj.singleton_class.class_eval do
      def no_name!
      end
    end

    assert_raises Striuct::ConditionError do
      sth.catch_name_error = obj
    end
  end

  def test_or
    sth = Sth.new

    assert_raises Striuct::ConditionError do
      sth.all_pass = 11
    end
    
    sth.all_pass = 1
    assert_equal 1, sth.all_pass
    sth.all_pass = 4
    assert_equal 4, sth.all_pass
    assert_equal true, sth.valid?(:all_pass)
  end

  def test_and
    sth = Sth.new

    assert_raises Striuct::ConditionError do
      sth.has_ignore = 1
    end

    assert_raises Striuct::ConditionError do
      sth.has_ignore= 2
    end
  
    sth.has_ignore = 3
    assert_equal 3, sth.has_ignore
    assert_equal true, sth.valid?(:has_ignore)
    
    assert_raises Striuct::ConditionError do
      sth.has_ignore = []
    end
  end

  def test_nand
    sth = Sth.new

    assert_raises Striuct::ConditionError do
      sth.nand = 4
    end

    assert_raises Striuct::ConditionError do
      sth.nand = 4.5
    end
  
    sth.nand = 2
    assert_equal 2, sth.nand
    assert_equal true, sth.valid?(:nand)
    sth.nand = []
    assert_equal [], sth.nand
  end



  def test_member_of
    sth = Sth.new
    
    assert_raises Striuct::ConditionError do
      sth.one_of_member = 4
    end
  
    sth.one_of_member = 3
    assert_equal 3, sth.one_of_member
    assert_equal true, sth.valid?(:one_of_member)
  end
  
  def test_generics
    sth = Sth.new
    
    assert_raises Striuct::ConditionError do
      sth.list_only_int = [1, '2']
    end
  
    sth.list_only_int = [1, 2]
    assert_equal [1, 2], sth.list_only_int
    assert_equal true, sth.valid?(:list_only_int)
    sth.list_only_int = []
    assert_equal [], sth.list_only_int
    assert_equal true, sth.valid?(:list_only_int)
    sth.list_only_int << '2'
    assert_equal false, sth.valid?(:list_only_int)
  end
  
  def test_boolean
    sth = Sth.new
    
    assert_raises Striuct::ConditionError do
      sth.true_or_false = nil
    end
    
    assert_equal false, sth.valid?(:true_or_false)
  
    sth.true_or_false = true
    assert_equal true, sth.true_or_false
    assert_equal true, sth.valid?(:true_or_false)
    sth.true_or_false = false
    assert_equal false, sth.true_or_false
    assert_equal true, sth.valid?(:true_or_false)
  end
  
  def test_stringable
    sth = Sth.new
    obj = Object.new
    
    assert_raises Striuct::ConditionError do
      sth.like_str = obj
    end
  
    sth.like_str = 'str'
    assert_equal true, sth.valid?(:like_str)
    sth.like_str = :sym
    assert_equal true, sth.valid?(:like_str)
    
    obj.singleton_class.class_eval do
      def to_str
      end
    end
    
    sth.like_str = obj
    assert_equal true, sth.valid?(:like_str)
  end

  def test_responsible_arg1
    sth = Sth.new
    obj = Object.new
    
    assert_raises Striuct::ConditionError do
      sth.has_x = obj
    end
    
    obj.singleton_class.class_eval do
      def x
      end
    end
    
    sth.has_x = obj
    assert_equal obj, sth.has_x
    assert_equal true, sth.valid?(:has_x)
  end

  def test_responsible_arg2
    sth = Sth.new
    obj = Object.new
    
    assert_raises Striuct::ConditionError do
      sth.has_x_and_y = obj
    end
    
    obj.singleton_class.class_eval do
      def x
      end
    end
    
    assert_raises Striuct::ConditionError do
      sth.has_x_and_y = obj
    end
    
    obj.singleton_class.class_eval do
      def y
      end
    end
    
    sth.has_x_and_y = obj
    assert_equal obj, sth.has_x_and_y
    assert_equal true, sth.valid?(:has_x_and_y)
  end
end


class TestStriuctLock < Test::Unit::TestCase
  Sth = Striuct.new :foo, :bar
  Sth.__send__ :close
  
  def test_lock
    sth = Sth.new
    assert_equal false, sth.lock?(:foo)
    assert_equal false, sth.lock?(:bar)
    assert_equal false, sth.secure?
    sth.lock :bar
    assert_equal true, sth.lock?(:bar)
    assert_equal false, sth.secure?
  
    assert_raises RuntimeError do
     sth.bar = 1
    end
   
    sth.__send__ :unlock, :bar
    
    assert_equal false, sth.lock?(:bar)
    
    sth.bar = 1
    assert_equal 1, sth.bar
    
    sth.lock
    assert_equal true, sth.lock?(:foo)
    assert_equal true, sth.lock?(:bar)
    assert_equal true, sth.lock?
    
    assert_raises RuntimeError do
      sth.foo = 1
    end
    
    assert_equal true, sth.secure?
  end
end

class TestStriuctInherit < Test::Unit::TestCase
  Sth = Striuct.define do
    member :foo, String
    member :bar, OR(nil, Fixnum)
  end
  
  class SubSth < Sth
    member :hoge, OR(nil, 1..3)
  end
  
  class SubSubSth < SubSth
    member :rest, AND(/\d/, Symbol)
  end
  
  def test_inherit
    assert_equal [*Sth.members, :hoge], SubSth.members
    sth = Sth.new
    substh = SubSth.new

    assert_raises Striuct::ConditionError do
      substh.bar = 'str'
    end
    
    assert_raises Striuct::ConditionError do
      substh.hoge = 4
    end
    
    assert_raises NoMethodError do
      sth.hoge = 3
    end
    
    assert_raises NoMethodError do
      substh.rest = :a4
    end
    
    subsubsth = SubSubSth.new
    
    assert_raises Striuct::ConditionError do
      subsubsth.rest = 4
    end
    
    subsubsth.rest = :a4
    
    assert_equal :a4, subsubsth[:rest]
    
    assert_equal true, Sth.__send__(:closed?)
    assert_equal false, SubSth.__send__(:closed?)
    SubSth.__send__(:close)
    assert_equal true, SubSth.__send__(:closed?)
    assert_equal false, SubSubSth.__send__(:closed?)
    SubSubSth.__send__(:close)
    assert_equal true, SubSubSth.__send__(:closed?)
  end
end

class TestStriuctConstants < Test::Unit::TestCase
  def test_const_version
    assert_equal '0.2.3', Striuct::VERSION
    assert_equal true, Striuct::VERSION.frozen?
    assert_same Striuct::VERSION, Striuct::Version
  end
end

class TestStriuctConstants < Test::Unit::TestCase
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

class TestStriuct_to_Struct < Test::Unit::TestCase
  Sth = Striuct.define do
    member :name, String
    member :age, Integer
  end
  
  def test_to_struct_class
    klass = Sth.to_struct_class
    assert_equal 'Striuct::Structs::Sth', klass.to_s
    assert_same klass, Sth.to_struct_class
    assert_kind_of Struct, Sth.new.to_struct
    assert_kind_of Striuct::Structs::Sth, Sth.new.to_struct
    
    assert_raises RuntimeError do
      Striuct.new.new.to_struct
    end
    
    Striuct.new(:a, :b, :c).new.to_struct
    assert_equal 1, Striuct::Structs.constants.length
  end
end

class TestStriuctFlavors < Test::Unit::TestCase
  class MyClass
    def self.parse(v)
      raise unless /\A[a-z]+\z/ =~ v
      new
    end
  end
  
  Sth = Striuct.define do
    member :chomped, AND(Symbol, /[^\n]\z/), &WHEN(String, ->v{v.chomp.to_sym})
    member :no_reduced, Symbol, &->v{v.to_sym}
    member :reduced, Symbol, &FLAVORS(->v{v.to_s}, ->v{v.to_sym})
    member :integer, Integer, &PARSE(Integer)
    member :myobj, ->v{v.instance_of? MyClass}, &PARSE(MyClass)
  end
  
  def test_WHEN
    sth = Sth.new
    
    assert_raises Striuct::ConditionError do
      sth.chomped = :"a\n"
    end
    
    sth.chomped = "a\n"
    
    assert_equal :a, sth.chomped
    
    sth.chomped = :b
    assert_equal :b, sth.chomped
  end

  def test_REDUCE
    sth = Sth.new
    
    assert_raises Striuct::ConditionError do
      sth.no_reduced = 1
    end
    
    sth.reduced = 1
    
    assert_equal :'1', sth.reduced
  end
  
  def test_PARSE
    sth = Sth.new
    
    assert_raises Striuct::ConditionError do
      sth.integer = '1.0'
    end
    
    sth.integer = '1'
    
    assert_equal 1, sth.integer
    
    assert_raises Striuct::ConditionError do
      sth.myobj = '1'
    end
    
    sth.myobj = 'a'
    
    assert_kind_of MyClass, sth.myobj
  end
end

class TestGetterValidation < Test::Unit::TestCase
  Sth = Striuct.define do
    member :plus_getter, /./, getter_validation: true
    member :only_getter, /./, getter_validation: true,
                              setter_validation: false
  end
  
  def test_getter_validation
    sth = Sth.new
    
    assert_raises Striuct::ConditionError do
      sth.plus_getter = ''
    end
    
    sth.plus_getter = 'abc'
    assert_equal 'abc', sth.plus_getter
    sth.plus_getter.clear
    
    assert_raises Striuct::ConditionError do
      sth.plus_getter
    end
    
    sth.only_getter = ''
    
    assert_raises Striuct::ConditionError do
      sth.only_getter
    end
  end
end
