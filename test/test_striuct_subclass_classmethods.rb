require_relative 'helper'

class TestStriuctSubclassClassMethods < Test::Unit::TestCase

  class User < Striuct.new
    member :id, Integer
    member :last_name, /\A\w+\z/
    member :family_name, /\A\w+\z/
    member :address, /\A((\w+) ?)+\z/
    member :age, ->age{(20..140).include? age}
  end
  
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
    
    assert_raises Validation::InvalidWritingError do
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
