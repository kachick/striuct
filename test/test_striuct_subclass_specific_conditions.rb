require_relative 'helper'

class TestStriuctSpecificConditions < Test::Unit::TestCase

  Sth = Striuct.define do
    member :list_only_int, GENERICS(Integer)
    member :true_or_false, BOOL?
    member :like_str, STRINGABLE?
    member :has_x, CAN(:x)
    member :has_x_and_y, CAN(:x, :y)
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
      def no_name!
      end
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
  
  def test_generics
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
    sth.like_str = :sym
    assert_equal true, sth.valid?(:like_str)
    
    obj.singleton_class.class_eval do
      def to_str
      end
    end
    
    sth.like_str = obj
    assert_equal true, sth.valid?(:like_str)
  end

  def test_responsible_arg1
    sth = Sth.new
    obj = Object.new
    
    assert_raises Validation::InvalidWritingError do
      sth.has_x = obj
    end
    
    obj.singleton_class.class_eval do
      def x
      end
    end
    
    sth.has_x = obj
    assert_equal obj, sth.has_x
    assert_equal true, sth.valid?(:has_x)
  end

  def test_responsible_arg2
    sth = Sth.new
    obj = Object.new
    
    assert_raises Validation::InvalidWritingError do
      sth.has_x_and_y = obj
    end
    
    obj.singleton_class.class_eval do
      def x
      end
    end
    
    assert_raises Validation::InvalidWritingError do
      sth.has_x_and_y = obj
    end
    
    obj.singleton_class.class_eval do
      def y
      end
    end
    
    sth.has_x_and_y = obj
    assert_equal obj, sth.has_x_and_y
    assert_equal true, sth.valid?(:has_x_and_y)
  end

end
