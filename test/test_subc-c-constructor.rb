require_relative 'helper'

class Test_Striuct_Subclass_Class_Constructor < Test::Unit::TestCase

  User = Striuct.define do
    member :name, AND(String, NOT(''))
    member :age, Fixnum
  end.freeze
  
  [:for_values, :new].each do |callee|
    define_method :"test_subclass_#{callee}" do
      user = User.public_send callee
      assert_instance_of User, user
      assert_not_kind_of Class, user
      assert_equal [:name, :age], user.members
      assert_equal [nil, nil], user.values
      
      assert_raises Validation::InvalidWritingError do
        User.public_send callee, :SYMBOL
      end
      
      assert_raises Validation::InvalidWritingError do
        User.public_send callee, ''
      end
      
      user = User.public_send callee, '.'
      assert_instance_of User, user
      assert_not_kind_of Class, user
      assert_equal ['.', nil], user.values
      
      assert_raises Validation::InvalidWritingError do
        User.public_send callee, '.', 1.0
      end
      
      user = User.public_send callee, '.', 1
      assert_equal ['.', 1], user.values
    end
  end
  
  def test_define
    user = User.define{|r|r.age = 1; r.name = 'a'}
    assert_same 1, user.age
    
    assert_raises RuntimeError do
      user.age = 1
    end
    
    user = User.define{|r|r.age = 1; r.name = 'a'}
    assert_same 1, user.age
    assert_same true, user.all_locked?
    assert_same false, user.frozen?
    
    assert_raises RuntimeError do
      User.define{|r|r.age = 1}
    end
    
    user = User.define(lock: true){|r|r.age = 1; r.name = 'a'}
    assert_same 1, user.age
    assert_same true, user.all_locked?
    user = User.define(lock: false){|r|r.age = 1; r.name = 'a'}
    assert_same false, user.all_locked?
    assert_equal true, user.strict?
    
    assert_raises Validation::InvalidWritingError do
      User.define{|r|r.age = 1; r.name = 'a'; r.name.clear}
    end
    
    user = User.define(strict: false){|r|r.age = 1; r.name = 'a'; r.name.clear}
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
