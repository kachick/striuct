require_relative 'helper'

class Test_Striuct_Subclass_Validation_Util < Test::Unit::TestCase

  ALWAYS_OCCUR_ERROR = ->_{raise Exception}
  peep = nil
  
  Foo = Striuct.define do
    member :foo, nil
    member :bar, ALWAYS_OCCUR_ERROR
    member :hoge
    peep = AND(String, /./)
    member :some_str, peep
  end

  SOME_STR = peep

  def test_predicate_restrict?
    assert_same true, Foo.restrict?(:foo)
    assert_same true, Foo.restrict?(:bar)
    assert_same false, Foo.restrict?(:hoge)
    assert_same true, Foo.new.restrict?(:foo)
    assert_same true, Foo.new.restrict?(:bar)
    assert_same false, Foo.new.restrict?(:hoge)
  end

  def test_predicate_with_condition?
    assert_same true, Foo.with_condition?(:foo)
    assert_same true, Foo.with_condition?(:bar)
    assert_same false, Foo.with_condition?(:hoge)
    assert_same true, Foo.new.with_condition?(:foo)
    assert_same true, Foo.new.with_condition?(:bar)
    assert_same false, Foo.new.with_condition?(:hoge)
  end

  def test_predicate_instance_sufficient?
    foo = Foo.new
    assert_same true, foo.sufficient?(:foo)
    assert_same false, foo.sufficient?(:bar)
    assert_same true, foo.sufficient?(:hoge)
    assert_same false, foo.sufficient?(:some_str)
    foo.some_str = ':)'
    assert_same true, foo.sufficient?(:some_str)
    foo.some_str.clear
    assert_same false, foo.sufficient?(:some_str)
  end

  def test_condition_for
    foo = Foo.new
    assert_same nil, foo.condition_for(:foo)
    assert_same ALWAYS_OCCUR_ERROR, foo.condition_for(:bar)
    assert_raises KeyError do
      foo.condition_for(:hoge)
    end
    assert_same SOME_STR, foo.condition_for(:some_str)
  end


end
