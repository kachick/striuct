require_relative 'helper'

class Test_Striuct_Subclass_Class_Inheritable < Test::Unit::TestCase

  Sth = Striuct.define do
    member :foo, String
    member :bar, OR(nil, Integer)
  end
  
  class SubSth < Sth
    member :hoge, OR(nil, 1..3)
  end
  
  class SubSubSth < SubSth
    member :rest, AND(/\d/, Symbol)
  end
  
  def test_inherit
    assert_equal [*Sth.members, :hoge], SubSth.members
    sth = Sth.new
    substh = SubSth.new

    assert_raises Validation::InvalidWritingError do
      substh.bar = 'str'
    end
    
    assert_raises Validation::InvalidWritingError do
      substh.hoge = 4
    end
    
    assert_raises NoMethodError do
      sth.hoge = 3
    end
    
    assert_raises NoMethodError do
      substh.rest = :a4
    end
    
    subsubsth = SubSubSth.new
    
    assert_raises Validation::InvalidWritingError do
      subsubsth.rest = 4
    end
    
    subsubsth.rest = :a4
    
    assert_equal :a4, subsubsth[:rest]
    
    assert_equal true, Sth.__send__(:closed?)
    assert_equal false, SubSth.__send__(:closed?)
    SubSth.__send__(:close)
    assert_equal true, SubSth.__send__(:closed?)
    assert_equal false, SubSubSth.__send__(:closed?)
    SubSubSth.__send__(:close)
    assert_equal true, SubSubSth.__send__(:closed?)
  end

end