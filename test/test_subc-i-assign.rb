# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Subclass_Instance_Assign < Test::Unit::TestCase

  Sth = Striuct.new do
    member :foo
  end

  [:unassign, :delete_at].each do |callee|
    define_method :"test_#{callee}" do
      sth = Sth.new
      assert_equal false, sth.assign?(:foo)
      assert_equal false, sth.assigned?(:foo)
      sth.foo = nil
      assert_equal true, sth.assign?(:foo)
      assert_equal true, sth.assigned?(:foo)
      sth.public_send callee, :foo
      assert_equal false, sth.assign?(:foo)
      assert_equal false, sth.assigned?(:foo)
      sth.foo = nil
      assert_equal true, sth.assign?(:foo)
      assert_equal true, sth.assigned?(:foo)
      sth.public_send callee, 0
      assert_equal false, sth.assign?(:foo)

      assert_raises KeyError do
        sth.public_send callee, :var
      end

      assert_raises KeyError do
        sth.public_send callee, 1
      end
    end
  end

  def test_empty?
    cls = Striuct.new :foo, :bar
    sth = cls.new

    assert_same true, sth.empty?

    sth.foo = nil
    assert_same false, sth.empty?
    sth.bar = true
    assert_same false, sth.empty?
    sth.unassign :foo
    assert_same false, sth.empty?
    sth.unassign :bar

    assert_same true, sth.empty?
  end

end
