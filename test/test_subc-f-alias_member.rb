# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Subclass_AliasMember < Test::Unit::TestCase

  class Sth < Striuct.new
    member :foo, String

    member :bar, Integer do |v|
      v
    end

    member :hoge, Symbol
    default :hoge, :Z
    alias_member :abc, :bar
    default :abc, 8
  end

  def test_alias_member
    sth = Sth.new 'A'
    assert_equal [:foo, :bar, :hoge], sth.members
    assert_equal [:foo, :bar, :hoge], sth.autonyms
    assert_equal({abc: :bar}, sth.aliases)
    assert_equal [:foo, :bar, :hoge, :abc], sth.all_members

    assert_equal 8, sth[:abc]
    adjuster = Sth.__send__(:adjuster_for, :abc)
    assert_kind_of Proc, adjuster
    assert_same adjuster, Sth.__send__(:adjuster_for, :bar)
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
