require_relative 'helper'

TopLevelSthForTest_to_Struct = Striuct.define do
  member :name, String
  member :age, Integer
end

class Test_Striuct_Subclass_to_Struct < Test::Unit::TestCase

  NestedSth = Striuct.define do
    member :name, String
    member :age, Integer
  end
  
  def teardown
    constants = Striuct::Structs.constants
    constants.each do |cons|
      Striuct::Structs.__send__ :remove_const, cons
    end
  end
  
  alias_method :setup, :teardown
  
  def test_raise
    assert_raises RuntimeError do
      Striuct.new.new.to_struct
    end
  end
  
  def test_noname
    assert_same 0, Striuct::Structs.constants.length
    struct_cls = Striuct.new(:a, :b, :c).new.to_struct
    assert_equal [:a, :b, :c], struct_cls.members
    assert_same 0, Striuct::Structs.constants.length
  end
  
  def test_to_nested_struct
    assert_same 0, Striuct::Structs.constants.length
    struct_cls = NestedSth.to_struct_class
    assert_same Struct, struct_cls.superclass
    assert_equal [:name, :age], struct_cls.members
    assert_same 1, Striuct::Structs.constants.length
    assert_equal 'Striuct::Structs::NestedSth', struct_cls.name
    assert_same struct_cls, NestedSth.to_struct_class
    assert_kind_of Struct, NestedSth.new.to_struct
    assert_instance_of Striuct::Structs::NestedSth, NestedSth.new.to_struct
  end
  
  def test_to_toplevel_struct
    assert_same 0, Striuct::Structs.constants.length
    struct_cls = TopLevelSthForTest_to_Struct.to_struct_class
    assert_same Struct, struct_cls.superclass
    assert_equal [:name, :age], struct_cls.members
    assert_same 1, Striuct::Structs.constants.length
    assert_equal 'Striuct::Structs::TopLevelSthForTest_to_Struct', struct_cls.name
    assert_same struct_cls, TopLevelSthForTest_to_Struct.to_struct_class
    assert_kind_of Struct, TopLevelSthForTest_to_Struct.new.to_struct
    assert_instance_of Striuct::Structs::TopLevelSthForTest_to_Struct, TopLevelSthForTest_to_Struct.new.to_struct
  end

end
