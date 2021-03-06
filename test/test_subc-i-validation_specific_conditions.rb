# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Subclass_Instance_SpecificConditions < Test::Unit::TestCase

  Sth = Striuct.define do
    member :list_only_int, SEND(:all?, Integer)
    member :true_or_false, BOOLEAN()
    member :has_foo, CAN(:foo)
    member :has_foo_and_bar, CAN(:foo, :bar)
    member :has_ignore, AND(1..5, 3..10)
    member :nand, NAND(1..5, 3..10)
    member :some_range, OR(1..5, 3..10)
    member :rescue_error, RESCUE(NoMethodError, -> v {v.no_name!})
    member :no_exception, QUIET(->v{v.class})
    member :not_integer, NOT(Integer)
  end

  def test_not
    sth = Sth.new

    obj = Object.new

    sth.not_integer = obj
    assert_same obj, sth.not_integer

    assert_raises Striuct::InvalidWritingError do
      sth.not_integer = 1
    end
  end


  def test_still
    sth = Sth.new

    obj = Object.new

    sth.no_exception = obj
    assert_same obj, sth.no_exception
    sth.no_exception = false

    obj.singleton_class.class_eval do
      undef_method :class
    end

    assert_raises Striuct::InvalidWritingError do
      sth.no_exception = obj
    end
  end

  def test_catch
    sth = Sth.new

    obj = Object.new

    sth.rescue_error = obj
    assert_same obj, sth.rescue_error
    sth.rescue_error = false

    obj.singleton_class.class_eval do
      def no_name!; end
    end

    assert_raises Striuct::InvalidWritingError do
      sth.rescue_error = obj
    end
  end

  def test_or_with_some_range
    sth = Sth.new

    assert_raises Striuct::InvalidWritingError do
      sth.some_range = 11
    end

    sth.some_range = 1
    assert_equal 1, sth.some_range
    sth.some_range = 4
    assert_equal 4, sth.some_range
    assert_equal true, sth.valid?(:some_range)
  end

  def test_and
    sth = Sth.new

    assert_raises Striuct::InvalidWritingError do
      sth.has_ignore = 1
    end

    assert_raises Striuct::InvalidWritingError do
      sth.has_ignore= 2
    end

    sth.has_ignore = 3
    assert_equal 3, sth.has_ignore
    assert_equal true, sth.valid?(:has_ignore)

    assert_raises Striuct::InvalidWritingError do
      sth.has_ignore = []
    end
  end

  def test_nand
    sth = Sth.new

    assert_raises Striuct::InvalidWritingError do
      sth.nand = 4
    end

    assert_raises Striuct::InvalidWritingError do
      sth.nand = 4.5
    end

    sth.nand = 2
    assert_equal 2, sth.nand
    assert_equal true, sth.valid?(:nand)
    sth.nand = []
    assert_equal [], sth.nand
  end

  def test_all
    sth = Sth.new

    assert_raises Striuct::InvalidWritingError do
      sth.list_only_int = [1, '2']
    end

    sth.list_only_int = [1, 2]
    assert_equal [1, 2], sth.list_only_int
    assert_equal true, sth.valid?(:list_only_int)
    sth.list_only_int = []
    assert_equal [], sth.list_only_int
    assert_equal true, sth.valid?(:list_only_int)
    sth.list_only_int << '2'
    assert_equal false, sth.valid?(:list_only_int)
  end

  def test_boolean
    sth = Sth.new

    assert_raises Striuct::InvalidWritingError do
      sth.true_or_false = nil
    end

    assert_equal false, sth.valid?(:true_or_false)

    sth.true_or_false = true
    assert_equal true, sth.true_or_false
    assert_equal true, sth.valid?(:true_or_false)
    sth.true_or_false = false
    assert_equal false, sth.true_or_false
    assert_equal true, sth.valid?(:true_or_false)
  end

  def test_responsible_arg1
    sth = Sth.new
    obj = Object.new

    raise if obj.respond_to? :foo

    assert_raises Striuct::InvalidWritingError do
      sth.has_foo = obj
    end

    obj.singleton_class.class_eval do
      def foo; end
    end

    raise unless obj.respond_to? :foo

    sth.has_foo = obj
    assert_equal obj, sth.has_foo
    assert_equal true, sth.valid?(:has_foo)
  end

  def test_responsible_arg2
    sth = Sth.new
    obj = Object.new

    raise if obj.respond_to? :foo
    raise if obj.respond_to? :bar

    assert_raises Striuct::InvalidWritingError do
      sth.has_foo_and_bar = obj
    end

    obj.singleton_class.class_eval do
      def foo; end
    end

    assert_raises Striuct::InvalidWritingError do
      sth.has_foo_and_bar = obj
    end

    raise unless obj.respond_to? :foo

    obj.singleton_class.class_eval do
      def bar; end
    end

    raise unless obj.respond_to? :bar

    sth.has_foo_and_bar = obj
    assert_equal obj, sth.has_foo_and_bar
    assert_equal true, sth.valid?(:has_foo_and_bar)
  end

end

class Test_Striuct_Subclass_Instance_SpecificConditions_FunctionalCondition < Test::Unit::TestCase

  Sthlambda = Striuct.new do
    member :lank, ->lank{lanks.include? lank}
    member :lanks
    default :lanks, 1..30
  end

  def test_lambda
    sth = Sthlambda.new
    sth.lank = 2
    assert_equal 2, sth.lank

    assert_raises Striuct::InvalidWritingError do
      sth.lank = 31
    end
  end

  max = 9

  SthProc = Striuct.new do
    member :lank, Proc.new{|n|(3..max) === n}
  end

  def test_Proc
    sth = SthProc.new
    sth.lank = 8
    assert_equal 8, sth.lank

    assert_raises Striuct::InvalidWritingError do
      sth.lank = 2
    end
  end

  SthMethod = Striuct.new do
    member :lank, 7.method(:<)
  end

  def test_Method
    sth = SthMethod.new
    sth.lank = 8
    assert_equal 8, sth.lank

    assert_raises Striuct::InvalidWritingError do
      sth.lank = 6
    end
  end

end
