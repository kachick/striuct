require_relative 'helper'

class Test_Striuct_Subclass_Instance_Setter < Test::Unit::TestCase

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

end

class Test_Striuct_Subclass_Instance_Accessor_With_Validation < Test::Unit::TestCase

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


class Test_Striuct_Subclass_Instance_Accsessor < Test::Unit::TestCase

  class Sth < Striuct.new
    member :bool, OR(true, false)
    member :sth
    conflict_management :struct do
      member :lambda, OR(->v{v % 3 == 2}, ->v{v.kind_of? Float})
    end
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
