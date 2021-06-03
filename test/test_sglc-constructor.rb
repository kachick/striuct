# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Constructor < Test::Unit::TestCase

  def test_new
    cls = Striuct.new
    assert_not_instance_of Striuct, cls
    assert_instance_of Class, cls
    assert_kind_of Striuct, cls.new

    cls2 = Striuct.new :name, :age

    assert_equal cls2.members, [:name, :age]

    cls3 = Striuct.new :foo do
      member :var
    end

    assert_equal cls3.members, [:foo, :var]
  end

  def test_define
    assert_raises RuntimeError do
      Striuct.define do
      end
    end

    klass = Striuct.define do
      member :foo
    end

    assert_equal true, klass.closed?
  end

end

