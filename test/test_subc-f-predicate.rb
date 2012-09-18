require_relative 'helper'

class Test_Striuct_Subclass_Predicate < Test::Unit::TestCase

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

  def test_has_key?
    assert_same true, Subclass.has_key?(0)
    assert_same true, Subclass.has_key?(1)
    assert_same false, Subclass.has_key?(2)
    assert_same false, Subclass.has_key?(99 * 99)
    assert_same true, Subclass.has_key?(-1)
    assert_same true, Subclass.has_key?(-2)
    assert_same false, Subclass.has_key?(-3)
    assert_same false, Subclass.has_key?(-(99 * 99))
    assert_same true, Subclass.has_key?(0.1)
    assert_same true, Subclass.has_key?(1.9)
    assert_same false, Subclass.has_key?('1')
    assert_same true, Subclass.has_key?(:foo)
    assert_same true, Subclass.has_key?(:bar)
    assert_same true, Subclass.has_key?(:aliased)
    assert_same false, Subclass.has_key?(:xyz)
    assert_same false, Subclass.has_key?(BasicObject.new)
    assert_same true, Subclass.has_key?('foo')
    assert_same true, Subclass.has_key?('bar')
    assert_same true, Subclass.has_key?('aliased')
    assert_same false, Subclass.has_key?('xyz')
    
    assert_same true, INSTANCE.has_key?(0)
    assert_same true, INSTANCE.has_key?(1)
    assert_same false, INSTANCE.has_key?(2)
    assert_same false, INSTANCE.has_key?(99 * 99)
    assert_same true, INSTANCE.has_key?(-1)
    assert_same true, INSTANCE.has_key?(-2)
    assert_same false, INSTANCE.has_key?(-3)
    assert_same false, INSTANCE.has_key?(-(99 * 99))
    assert_same true, INSTANCE.has_key?(0.1)
    assert_same true, INSTANCE.has_key?(1.9)
    assert_same false, INSTANCE.has_key?('1')
    assert_same true, INSTANCE.has_key?(:foo)
    assert_same true, INSTANCE.has_key?(:bar)
    assert_same true, INSTANCE.has_key?(:aliased)
    assert_same false, INSTANCE.has_key?(:xyz)
    assert_same false, INSTANCE.has_key?(BasicObject.new)
    assert_same true, INSTANCE.has_key?('foo')
    assert_same true, INSTANCE.has_key?('bar')
    assert_same true, INSTANCE.has_key?('aliased')
    assert_same false, INSTANCE.has_key?('xyz')
  end

  def test_with_aliases?
    assert_same false, Subclass.with_aliases?(:foo)
    assert_same true, Subclass.with_aliases?(:bar)
    assert_same false, Subclass.with_aliases?(:aliased)
    assert_same false, Subclass.with_aliases?(:xyz)
    assert_same false, Subclass.with_aliases?(1)
    assert_same false, Subclass.with_aliases?(BasicObject.new)
    assert_same false, Subclass.with_aliases?('foo')
    assert_same true, Subclass.with_aliases?('bar')
    assert_same false, Subclass.with_aliases?('aliased')
    assert_same false, Subclass.with_aliases?('xyz')
    
    assert_same false, INSTANCE.with_aliases?(:foo)
    assert_same true, INSTANCE.with_aliases?(:bar)
    assert_same false, INSTANCE.with_aliases?(:aliased)
    assert_same false, INSTANCE.with_aliases?(:xyz)
    assert_same false, INSTANCE.with_aliases?(1)
    assert_same false, INSTANCE.with_aliases?(BasicObject.new)
    assert_same false, INSTANCE.with_aliases?('foo')
    assert_same true, INSTANCE.with_aliases?('bar')
    assert_same false, INSTANCE.with_aliases?('aliased')
    assert_same false, INSTANCE.with_aliases?('xyz')
  end

end
