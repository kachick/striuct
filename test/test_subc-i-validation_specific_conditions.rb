# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Subclass_Instance_SpecificConditions < Test::Unit::TestCase

  Sth = Striuct.define do
    member :list_only_int, ALL(Integer)
    member :true_or_false, boolean
    member :like_str, stringable
    member :has_foo, CAN(:foo)
    member :has_foo_and_bar, CAN(:foo, :bar)
    member :one_of_member, MEMBER_OF([1, 3])
    member :has_ignore, AND(1..5, 3..10)
    member :nand, NAND(1..5, 3..10)
    member :all_pass, OR(1..5, 3..10)
    member :catch_error, CATCH(NoMethodError){|v|v.no_name!}
    member :no_exception, QUIET(->v{v.class})
    member :not_integer, NOT(Integer)
  end

  def test_not
    sth = Sth.new

    obj = Object.new

    sth.not_integer = obj
    assert_same obj, sth.not_integer

    assert_raises Validation::InvalidWritingError do
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

    assert_raises Validation::InvalidWritingError do
      sth.no_exception = obj
    end
  end

  def test_catch
    sth = Sth.new

    obj = Object.new

    sth.catch_error = obj
    assert_same obj, sth.catch_error
    sth.catch_error = false

    obj.singleton_class.class_eval do
      def no_name!; end
    end

    assert_raises Validation::InvalidWritingError do
      sth.catch_error = obj
    end
  end

  def test_or
    sth = Sth.new

    assert_raises Validation::InvalidWritingError do
      sth.all_pass = 11
    end

    sth.all_pass = 1
    assert_equal 1, sth.all_pass
    sth.all_pass = 4
    assert_equal 4, sth.all_pass
    assert_equal true, sth.valid?(:all_pass)
  end

  def test_and
    sth = Sth.new

    assert_raises Validation::InvalidWritingError do
      sth.has_ignore = 1
    end

    assert_raises Validation::InvalidWritingError do
      sth.has_ignore= 2
    end

    sth.has_ignore = 3
    assert_equal 3, sth.has_ignore
    assert_equal true, sth.valid?(:has_ignore)

    assert_raises Validation::InvalidWritingError do
      sth.has_ignore = []
    end
  end

  def test_nand
    sth = Sth.new

    assert_raises Validation::InvalidWritingError do
      sth.nand = 4
    end

    assert_raises Validation::InvalidWritingError do
      sth.nand = 4.5
    end

    sth.nand = 2
    assert_equal 2, sth.nand
    assert_equal true, sth.valid?(:nand)
    sth.nand = []
    assert_equal [], sth.nand
  end

  def test_member_of
    sth = Sth.new

    assert_raises Validation::InvalidWritingError do
      sth.one_of_member = 4
    end

    sth.one_of_member = 3
    assert_equal 3, sth.one_of_member
    assert_equal true, sth.valid?(:one_of_member)
  end

  def test_all
    sth = Sth.new

    assert_raises Validation::InvalidWritingError do
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

    assert_raises Validation::InvalidWritingError do
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

  def test_stringable
    sth = Sth.new
    obj = Object.new

    assert_raises Validation::InvalidWritingError do
      sth.like_str = obj
    end

    sth.like_str = 'str'
    assert_equal true, sth.valid?(:like_str)

    obj.singleton_class.class_eval do
      def to_str; end
    end

    sth.like_str = obj
    assert_equal true, sth.valid?(:like_str)
  end

  def test_responsible_arg1
    sth = Sth.new
    obj = Object.new

    raise if obj.respond_to? :foo

    assert_raises Validation::InvalidWritingError do
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

    assert_raises Validation::InvalidWritingError do
      sth.has_foo_and_bar = obj
    end

    obj.singleton_class.class_eval do
      def foo; end
    end

    assert_raises Validation::InvalidWritingError do
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

    assert_raises Validation::InvalidWritingError do
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

    assert_raises Validation::InvalidWritingError do
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

    assert_raises Validation::InvalidWritingError do
      sth.lank = 6
    end
  end

end
