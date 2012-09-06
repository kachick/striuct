require_relative 'helper'

class Test_Striuct_Subclass_to_Struct < Test::Unit::TestCase

  Sth = Striuct.define do
    member :name, String
    member :age, Integer
  end
  
  def test_to_struct_class
    klass = Sth.to_struct_class
    assert_equal 'Striuct::Structs::Sth', klass.to_s
    assert_same klass, Sth.to_struct_class
    assert_kind_of Struct, Sth.new.to_struct
    assert_kind_of Striuct::Structs::Sth, Sth.new.to_struct
    
    assert_raises RuntimeError do
      Striuct.new.new.to_struct
    end
    
    Striuct.new(:a, :b, :c).new.to_struct
    assert_equal 1, Striuct::Structs.constants.length
  end

end
