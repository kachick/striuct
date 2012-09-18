require_relative 'helper'

class Test_Striuct_Subclass_Class_Constructor < Test::Unit::TestCase

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
  
  def test_new
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
    assert_same true, user.all_locked?
    assert_same false, user.frozen?
    
    assert_raises RuntimeError do
      User2.define{|r|r.age = 1}
    end
    
    user = User2.define(lock: true){|r|r.age = 1; r.name = 'a'}
    assert_same 1, user.age
    assert_same true, user.all_locked?
    user = User2.define(lock: false){|r|r.age = 1; r.name = 'a'}
    assert_same false, user.all_locked?
    assert_equal true, user.strict?
    
    assert_raises Validation::InvalidWritingError do
      User2.define{|r|r.age = 1; r.name = 'a'; r.name.clear}
    end
    
    user = User2.define(strict: false){|r|r.age = 1; r.name = 'a'; r.name.clear}
    assert_equal '', user.name
    assert_equal false, user.strict?
  end
  
  Sth = Striuct.new :foo, :bar, :hoge
  SampleStruct = Struct.new :foo, :bar, :hoge
  
  def test_for_pairs_from_hash
    sth = Sth[hoge: 7, foo: 8]
   
    assert_equal [8, nil, 7], sth.values
  end

  def test_for_pairs_from_struct
    sth = Sth[SampleStruct.new 8, nil, 7]
   
    assert_equal [8, nil, 7], sth.values
  end

end  
