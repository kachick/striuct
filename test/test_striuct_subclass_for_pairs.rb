require_relative 'helper'

class TestStriuctForPairs < Test::Unit::TestCase

  Sth = Striuct.new :foo, :bar, :hoge
  
  def test_for_pairs
    sth = Sth[hoge: 7, foo: 8]
   
    assert_equal [8, nil, 7], sth.values
  end

end
