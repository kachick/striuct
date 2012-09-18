require_relative 'helper'

class Test_Striuct_Subclass_BasicPredicate < Test::Unit::TestCase

  class Subclass < Striuct
    member :foo    
    member :bar
    alias_member :aliased, :bar
    close_member
  end.freeze

  INSTANCE = Subclass.new.freeze
  
  TYPE_PAIRS = {
    class: Subclass,
    instance: INSTANCE
  }.freeze

  [:autonym?, :has_autonym?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same true, reciever.public_send(predicate, :foo)
        assert_same true, reciever.public_send(predicate, :bar)
        assert_same false, reciever.public_send(predicate, :aliased)
        assert_same false, reciever.public_send(predicate, :xyz)
        assert_same false, reciever.public_send(predicate, 1)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
        assert_same true, reciever.public_send(predicate, 'foo')
        assert_same true, reciever.public_send(predicate, 'bar')
        assert_same false, reciever.public_send(predicate, 'aliased')
        assert_same false, reciever.public_send(predicate, 'xyz')
      end
    end
  end

  [:alias?, :has_alias?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same false, reciever.public_send(predicate, :foo)
        assert_same false, reciever.public_send(predicate, :bar)
        assert_same true, reciever.public_send(predicate, :aliased)
        assert_same false, reciever.public_send(predicate, :xyz)
        assert_same false, reciever.public_send(predicate, 1)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
        assert_same false, reciever.public_send(predicate, 'foo')
        assert_same false, reciever.public_send(predicate, 'bar')
        assert_same true, reciever.public_send(predicate, 'aliased')
        assert_same false, reciever.public_send(predicate, 'xyz')
      end
    end
  end

  [:member?, :has_member?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same true, reciever.public_send(predicate, :foo)
        assert_same true, reciever.public_send(predicate, :bar)
        assert_same true, reciever.public_send(predicate, :aliased)
        assert_same false, reciever.public_send(predicate, :xyz)
        assert_same false, reciever.public_send(predicate, 1)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
        assert_same true, reciever.public_send(predicate, 'foo')
        assert_same true, reciever.public_send(predicate, 'bar')
        assert_same true, reciever.public_send(predicate, 'aliased')
        assert_same false, reciever.public_send(predicate, 'xyz')
      end
    end
  end

  [:index?, :has_index?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same true, reciever.public_send(predicate, 0)
        assert_same true, reciever.public_send(predicate, 1)
        assert_same false, reciever.public_send(predicate, 2)
        assert_same false, reciever.public_send(predicate, 99 * 99)
        assert_same true, reciever.public_send(predicate, -1)
        assert_same true, reciever.public_send(predicate, -2)
        assert_same false, reciever.public_send(predicate, -3)
        assert_same false, reciever.public_send(predicate, -(99 * 99))
        assert_same true, reciever.public_send(predicate, 0.1)
        assert_same true, reciever.public_send(predicate, 1.9)
        assert_same false, reciever.public_send(predicate, '1')
        assert_same false, reciever.public_send(predicate, :foo)
        assert_same false, reciever.public_send(predicate, :bar)
        assert_same false, reciever.public_send(predicate, :aliased)
        assert_same false, reciever.public_send(predicate, :xyz)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
        assert_same false, reciever.public_send(predicate, 'foo')
        assert_same false, reciever.public_send(predicate, 'bar')
        assert_same false, reciever.public_send(predicate, 'aliased')
        assert_same false, reciever.public_send(predicate, 'xyz')
      end
    end
  end

  [:key?, :has_key?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same true, reciever.public_send(predicate, 0)
        assert_same true, reciever.public_send(predicate, 1)
        assert_same false, reciever.public_send(predicate, 2)
        assert_same false, reciever.public_send(predicate, 99 * 99)
        assert_same true, reciever.public_send(predicate, -1)
        assert_same true, reciever.public_send(predicate, -2)
        assert_same false, reciever.public_send(predicate, -3)
        assert_same false, reciever.public_send(predicate, -(99 * 99))
        assert_same true, reciever.public_send(predicate, 0.1)
        assert_same true, reciever.public_send(predicate, 1.9)
        assert_same false, reciever.public_send(predicate, '1')
        assert_same true, reciever.public_send(predicate, :foo)
        assert_same true, reciever.public_send(predicate, :bar)
        assert_same true, reciever.public_send(predicate, :aliased)
        assert_same false, reciever.public_send(predicate, :xyz)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
        assert_same true, reciever.public_send(predicate, 'foo')
        assert_same true, reciever.public_send(predicate, 'bar')
        assert_same true, reciever.public_send(predicate, 'aliased')
        assert_same false, reciever.public_send(predicate, 'xyz')
      end
    end
  end

  [:with_aliases?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same false, reciever.public_send(predicate, :foo)
        assert_same true, reciever.public_send(predicate, :bar)
        assert_same false, reciever.public_send(predicate, :aliased)
        assert_same false, reciever.public_send(predicate, :xyz)
        assert_same false, reciever.public_send(predicate, 1)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
        assert_same false, reciever.public_send(predicate, 'foo')
        assert_same true, reciever.public_send(predicate, 'bar')
        assert_same false, reciever.public_send(predicate, 'aliased')
        assert_same false, reciever.public_send(predicate, 'xyz')
      end
    end
  end

end


class Test_Striuct_Subclass_Predicate_Default < Test::Unit::TestCase

  class Subclass < Striuct
    member :foo    
    member :val, ANYTHING?, default: 'DEFAULT'
    member :lazy, ANYTHING?, default_proc: ->{} 
    alias_member :als_foo, :foo
    alias_member :als_val, :val
    alias_member :als_lazy, :lazy
    close_member
  end.freeze

  INSTANCE = Subclass.new.freeze
  
  TYPE_PAIRS = {
    class: Subclass,
    instance: INSTANCE
  }.freeze

  [:with_default?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same false, reciever.public_send(predicate, :foo)
        assert_same false, reciever.public_send(predicate, :als_foo)
        assert_same false, reciever.public_send(predicate, 'foo')
        assert_same false, reciever.public_send(predicate, 'als_foo')
        assert_same false, reciever.public_send(predicate, 0)
        assert_same false, reciever.public_send(predicate, 0.9)
        
        assert_same true, reciever.public_send(predicate, :val)
        assert_same true, reciever.public_send(predicate, :als_val)
        assert_same true, reciever.public_send(predicate, 'val')
        assert_same true, reciever.public_send(predicate, 'als_val')
        assert_same true, reciever.public_send(predicate, 1)
        assert_same true, reciever.public_send(predicate, 1.9)
        
        assert_same true, reciever.public_send(predicate, :lazy)
        assert_same true, reciever.public_send(predicate, :als_lazy)
        assert_same true, reciever.public_send(predicate, 'lazy')
        assert_same true, reciever.public_send(predicate, 'als_lazy')
        assert_same true, reciever.public_send(predicate, 2)
        assert_same true, reciever.public_send(predicate, 2.9)
        
        assert_same false, reciever.public_send(predicate, :none)
        assert_same false, reciever.public_send(predicate, 'none')
        assert_same false, reciever.public_send(predicate, 3)
        assert_same false, reciever.public_send(predicate, 3.9)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
      end
    end
  end

end
