require_relative 'helper'


class Test_Striuct_Subclass_Instance_Enum_old < Test::Unit::TestCase

  class User < Striuct.new
    member :id, Integer
    member :last_name, /\A\w+\z/
    member :family_name, /\A\w+\z/
    member :address, /\A((\w+) ?)+\z/
    member :age, ->age{(20..140).include? age}
  end
  
  def test_each
    user = User.new 9999, 'taro', 'yamada', 'Tokyo Japan', 30
    assert_same user, user.each{}
    assert_kind_of Enumerator, enum = user.each
    assert_equal enum.next, 9999
    assert_equal enum.next, 'taro'
  end
  
  def test_each_with_index
    user = User.new 9999, 'taro', 'yamada', 'Tokyo Japan', 30
    assert_same user, user.each_with_index{}
    assert_kind_of Enumerator, user.each_with_index
    
    r = []
    user.each_with_index do |value, index|
      r << [value, index]
    end
    
    assert_equal [user.each_value.to_a, user.each_index.to_a].transpose, r
  end

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

class Test_Striuct_Subclass_Enum < Test::Unit::TestCase
  
  class Subclass < Striuct
    member :foo
    member :bar

    close_member
  end.freeze

  INSTANCE = Subclass.new.freeze
  
  TYPE_PAIRS = {
    class: Subclass,
    instance: INSTANCE
  }.freeze

  [:each_autonym, :each_member].each do |callee|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{callee}" do
        assert_same(reciever, reciever.public_send(callee) {})
        
        enum = reciever.public_send(callee)
        assert_kind_of Enumerator, enum
        assert_same :foo, enum.next
        assert_same :bar, enum.next
        assert_raises StopIteration do
          enum.next
        end
      end
    end
  end

  [:each_autonym_with_index, :each_member_with_index].each do |callee|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{callee}" do
        assert_same(reciever, reciever.public_send(callee) {})
        
        enum = reciever.public_send(callee)
        assert_kind_of Enumerator, enum
        assert_equal [:foo, 0], enum.next
        assert_equal [:bar, 1], enum.next
        assert_raises StopIteration do
          enum.next
        end
      end
    end
  end
  
  [:each_index].each do |callee|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{callee}" do
        assert_same(reciever, reciever.public_send(callee) {})
        
        enum = reciever.public_send(callee)
        assert_kind_of Enumerator, enum
        assert_same 0, enum.next
        assert_same 1, enum.next
        assert_raises StopIteration do
          enum.next
        end
      end
    end
  end

end