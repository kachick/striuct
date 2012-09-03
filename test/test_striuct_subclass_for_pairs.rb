require_relative 'helper'

class TestStriuctForPairs < Test::Unit::TestCase

  Sth = Striuct.new :foo, :bar, :hoge
  SampleStruct = Struct.new :foo, :bar, :hoge
  
  def test_for_pairs_from_hash
    sth = Sth[hoge: 7, foo: 8]
   
    assert_equal [8, nil, 7], sth.values
  end

  def test_for_pairs_from_struct
    sth = Sth[SampleStruct.new 8, nil, 7]
   
    assert_equal [8, nil, 7], sth.values
  end

end
