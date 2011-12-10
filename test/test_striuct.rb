$VERBOSE = true
require File.dirname(__FILE__) + '/test_helper.rb'

class TestStriuct < Test::Unit::TestCase
  class User < Striuct.new
    member :id, Integer
    member :last_name, /\A\w+\z/
    member :family_name, /\A\w+\z/
    member :address, /\A((\w+) ?)+\z/
    member(:age) {|v|(20..140).include? v}
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
  
  def test_accessor
    user = User.new
    user[:last_name] = 'foo'
    assert_equal user.last_name, 'foo'
    user.last_name = 'bar'
    assert_equal user[:last_name], 'bar'
    
    assert_raises(Striuct::ConditionIsNotSatisfied){user[:last_name] = 'foo s'}
  end
end

