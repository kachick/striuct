# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Subclass_Class_Copy < Test::Unit::TestCase

  def test_dup
    org_cls = Striuct.define do
      member :sth
    end.freeze

    assert_same true, org_cls.frozen?
    assert_same true, org_cls.closed?
    cls2 = org_cls.dup
    assert_same true, org_cls.frozen?
    assert_same true, org_cls.closed?
    assert_same false, cls2.frozen?
    assert_same false, cls2.closed?
    cls2.__send__ :member, :dummy1
    assert_same false, org_cls.member?(:dummy1)
  end

  def test_clone
    org_cls = Striuct.define do
      member :sth
    end.freeze

    assert_same true, org_cls.frozen?
    assert_same true, org_cls.closed?
    cls2 = org_cls.clone
    assert_same true, org_cls.frozen?
    assert_same true, org_cls.closed?
    assert_same true, cls2.frozen?
    assert_same true, cls2.closed?
  end

  def test_dup_deep
    org_cls =  Striuct.define do
      member :foo, Numeric
    end

    foo = org_cls.new
    cls2 = org_cls.dup
    foo2 = cls2.new
    foo2.foo = 0.1
    assert_raises Striuct::InvalidWritingError do
      foo2.foo = '1'
    end

    foo.foo = 1

    assert_same 1, foo.foo
  end

  def test_clone_deep
    org_cls =  Striuct.define do
      member :foo, Numeric
    end

    foo = org_cls.new
    cls2 = org_cls.clone
    foo2 = cls2.new
    foo2.foo = 0.1
    assert_raises Striuct::InvalidWritingError do
      foo2.foo = '1'
    end

    foo.foo = 1

    assert_same 1, foo.foo
  end

end
