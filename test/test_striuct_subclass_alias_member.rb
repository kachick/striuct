require_relative 'helper'

class TestStriuctAliasMember < Test::Unit::TestCase

  class Sth < Striuct.new
    member :foo, String
    
    member :bar, Integer do |v|
      v
    end
    
    member :hoge, Symbol
    default :hoge, :'Z'
    alias_member :abc, :bar
    default :abc, 8
  end

  def test_alias_member
    sth = Sth.new 'A'
    assert_equal [:foo, :bar, :hoge], sth.members

    assert_equal 8, sth[:abc]
    flavor = Sth.__send__(:flavor_for, :abc)
    assert_kind_of Proc, flavor
    assert_same flavor, Sth.__send__(:flavor_for, :bar)
    assert_equal 8, sth.abc
    sth.abc = 5
    assert_equal 5, sth.bar
    sth[:abc] = 6
    assert_equal 6, sth.bar
    
    assert_raises Validation::InvalidWritingError do
      sth[:abc] = 'a'
    end
    
    assert_raises Validation::InvalidWritingError do
      sth.abc = 'a'
    end
    
    assert_raises Validation::InvalidWritingError do
      sth.bar = 'a'
    end
    
    assert_raises ArgumentError do
      Sth.class_eval do
        member :abc
      end
    end
  end

end