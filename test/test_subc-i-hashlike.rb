# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Subclass_Instance_HashLike < Test::Unit::TestCase

  Sth = Striuct.new :foo, :bar, :hoge

  def test_has_value?
    sth = Sth[hoge: 7, foo: 8]
    assert_equal true, sth.value?(7)
    assert_equal true, sth.value?(8)
    assert_equal false, sth.value?(9)
    assert_equal false, sth.value?(nil)
  end

  def test_select!
    sth = Sth[hoge: 7, foo: 8]
    sth2, sth3 = sth.dup, sth.dup

    assert_kind_of Enumerator, enum = sth.select!
    assert_equal [:foo, 8], enum.next
    assert_equal [:bar, nil], enum.next
    assert_equal [:hoge, 7], enum.next
    assert_raises StopIteration do
      enum.next
    end

    assert_equal nil, sth2.select!{|_k, _v|true}
    assert_equal sth3, sth3.select!{|k, v|k == :hoge && v == 7}
    assert_equal nil, sth3.foo
    assert_equal true, sth3.assign?(:hoge)
    assert_equal false, sth3.assign?(:foo)
    assert_equal 7, sth3.hoge
  end

  def test_keep_if
    sth = Sth[hoge: 7, foo: 8]
    sth2, sth3 = sth.dup, sth.dup

    assert_kind_of Enumerator, enum = sth.keep_if
    assert_equal [:foo, 8], enum.next
    assert_equal [:bar, nil], enum.next
    assert_equal [:hoge, 7], enum.next
    assert_raises StopIteration do
      enum.next
    end

    assert_equal sth2, sth2.keep_if{|_k, _v|true}
    assert_equal sth3, sth3.keep_if{|k, v|k == :hoge && v == 7}
    assert_equal nil, sth3.foo
    assert_equal true, sth3.assign?(:hoge)
    assert_equal false, sth3.assign?(:foo)
    assert_equal 7, sth3.hoge
  end

  def test_reject!
    sth = Sth[hoge: 7, foo: 8]
    sth2, sth3 = sth.dup, sth.dup

    assert_kind_of Enumerator, enum = sth.reject!
    assert_equal [:foo, 8], enum.next
    assert_equal [:bar, nil], enum.next
    assert_equal [:hoge, 7], enum.next
    assert_raises StopIteration do
      enum.next
    end

    enum.rewind
    assert_equal [:foo, 8], enum.next

    assert_equal nil, sth2.reject!{|_k, _v|false}
    assert_equal sth3, sth3.reject!{|k, v|k == :hoge && v == 7}
    assert_equal nil, sth3.hoge
    assert_equal false, sth3.assign?(:hoge)
    assert_equal true, sth3.assign?(:foo)
    assert_equal 8, sth3.foo
  end

  def test_delete_if
    sth = Sth[hoge: 7, foo: 8]
    sth2, sth3 = sth.dup, sth.dup

    assert_kind_of Enumerator, enum = sth.delete_if

    assert_equal [:foo, 8], enum.next
    assert_equal [:bar, nil], enum.next
    assert_equal [:hoge, 7], enum.next
    assert_raises StopIteration do
      enum.next
    end

    assert_equal sth2, sth2.delete_if{|_k, _v|false}
    assert_equal sth3, sth3.delete_if{|k, v|k == :hoge && v == 7}
    assert_equal nil, sth3.hoge
    assert_equal false, sth3.assign?(:hoge)
    assert_equal true, sth3.assign?(:foo)
    assert_equal 8, sth3.foo
  end

  def test_assoc
    sth = Sth[hoge: 7, foo: 8]

    assert_equal [:foo, 8], sth.assoc(:foo)
    assert_equal [:bar, nil], sth.assoc(:bar)
    assert_equal [:hoge, 7], sth.assoc(:hoge)

    assert_raises NameError do
      sth.assoc(:dummy)
    end
  end

  def test_rassoc
    sth = Sth[hoge: 7, foo: 7]

    assert_equal [:foo, 7], sth.rassoc(7)
    assert_equal [:bar, nil], sth.rassoc(nil)
    assert_equal nil, sth.rassoc(9)
  end

  def test_flatten
    sth = Sth[hoge: 7, foo: 8, bar: [1, 2]]
    assert_equal [:foo, 8, :bar, [1, 2], :hoge, 7], sth.flatten
    assert_equal [:foo, 8, :bar, [1, 2], :hoge, 7], sth.flatten(1)
    assert_equal [:foo, 8, :bar, 1, 2, :hoge, 7], sth.flatten(2)
    assert_equal [:foo, 8, :bar, 1, 2, :hoge, 7], sth.flatten(3)
    assert_equal [:foo, 8, :bar, 1, 2, :hoge, 7], sth.flatten(-1)
  end

  def test_select
    sth = Sth[hoge: 7, foo: 8]

    assert_kind_of Enumerator, sth.select

    assert_equal Sth[hoge: 7], sth.select{|k, _v|k == :hoge}
  end

  def test_reject
    # rubocop:disable Style/HashExcept
    sth = Sth[hoge: 7, foo: 8]

    assert_kind_of Enumerator, sth.reject

    assert_equal Sth[foo: 8], sth.reject{|k, _v|k == :hoge}
    # rubocop:enable Style/HashExcept
  end

end
