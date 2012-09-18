require_relative 'helper'

class Test_Striuct_Subclass_Predicate < Test::Unit::TestCase

  class FooBar < Striuct
    member :foo    
    member :bar
    alias_member :aliased, :bar
    close_member
  end

  INS = FooBar.new

  def test_has_autonym?
    assert_same true, INS.has_autonym?(:foo)
    assert_same true, INS.has_autonym?(:bar)
    assert_same false, INS.has_autonym?(:aliased)
    assert_same false, INS.has_autonym?(:xyz)
    assert_same false, INS.has_autonym?(1)
    assert_same false, INS.has_autonym?(BasicObject.new)
    assert_same true, INS.has_autonym?('foo')
    assert_same true, INS.has_autonym?('bar')
    assert_same false, INS.has_autonym?('aliased')
    assert_same false, INS.has_autonym?('xyz')
  end

  def test_has_alias?
    assert_same false, INS.has_alias?(:foo)
    assert_same false, INS.has_alias?(:bar)
    assert_same true, INS.has_alias?(:aliased)
    assert_same false, INS.has_alias?(:xyz)
    assert_same false, INS.has_alias?(1)
    assert_same false, INS.has_alias?(BasicObject.new)
    assert_same false, INS.has_alias?('foo')
    assert_same false, INS.has_alias?('bar')
    assert_same true, INS.has_alias?('aliased')
    assert_same false, INS.has_alias?('xyz')
  end

  def test_has_member?
    assert_same true, INS.has_member?(:foo)
    assert_same true, INS.has_member?(:bar)
    assert_same true, INS.has_member?(:aliased)
    assert_same false, INS.has_member?(:xyz)
    assert_same false, INS.has_member?(1)
    assert_same false, INS.has_member?(BasicObject.new)
    assert_same true, INS.has_member?('foo')
    assert_same true, INS.has_member?('bar')
    assert_same true, INS.has_member?('aliased')
    assert_same false, INS.has_member?('xyz')
  end

  def test_has_index?
    assert_same true, INS.has_index?(0)
    assert_same true, INS.has_index?(1)
    assert_same false, INS.has_index?(2)
    assert_same false, INS.has_index?(99 * 99)
    assert_same true, INS.has_index?(-1)
    assert_same true, INS.has_index?(-2)
    assert_same false, INS.has_index?(-3)
    assert_same false, INS.has_index?(-(99 * 99))
    assert_same true, INS.has_index?(0.1)
    assert_same true, INS.has_index?(1.9)
    assert_same false, INS.has_index?('1')
    assert_same false, INS.has_index?(:foo)
    assert_same false, INS.has_index?(:bar)
    assert_same false, INS.has_index?(:aliased)
    assert_same false, INS.has_index?(:xyz)
    assert_same false, INS.has_index?(BasicObject.new)
    assert_same false, INS.has_index?('foo')
    assert_same false, INS.has_index?('bar')
    assert_same false, INS.has_index?('aliased')
    assert_same false, INS.has_index?('xyz')
  end

  def test_has_key?
    assert_same true, INS.has_key?(0)
    assert_same true, INS.has_key?(1)
    assert_same false, INS.has_key?(2)
    assert_same false, INS.has_key?(99 * 99)
    assert_same true, INS.has_key?(-1)
    assert_same true, INS.has_key?(-2)
    assert_same false, INS.has_key?(-3)
    assert_same false, INS.has_key?(-(99 * 99))
    assert_same true, INS.has_key?(0.1)
    assert_same true, INS.has_key?(1.9)
    assert_same false, INS.has_key?('1')
    assert_same true, INS.has_key?(:foo)
    assert_same true, INS.has_key?(:bar)
    assert_same true, INS.has_key?(:aliased)
    assert_same false, INS.has_key?(:xyz)
    assert_same false, INS.has_key?(BasicObject.new)
    assert_same true, INS.has_key?('foo')
    assert_same true, INS.has_key?('bar')
    assert_same true, INS.has_key?('aliased')
    assert_same false, INS.has_key?('xyz')
  end

  def test_with_aliases?
    assert_same false, INS.with_aliases?(:foo)
    assert_same true, INS.with_aliases?(:bar)
    assert_same false, INS.with_aliases?(:aliased)
    assert_same false, INS.with_aliases?(:xyz)
    assert_same false, INS.with_aliases?(1)
    assert_same false, INS.with_aliases?(BasicObject.new)
    assert_same false, INS.with_aliases?('foo')
    assert_same true, INS.with_aliases?('bar')
    assert_same false, INS.with_aliases?('aliased')
    assert_same false, INS.with_aliases?('xyz')
  end

end
