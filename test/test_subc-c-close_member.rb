# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Subclass_Class_Close < Test::Unit::TestCase

  Sth = Striuct.new do
    member :foo
  end

  def test_class_close
    sth = Sth.new

    assert_equal true, sth.member?(:foo)

    Sth.class_eval do
      member :bar
    end

    assert_equal true, sth.member?(:bar)
    assert_equal [:foo, :bar], sth.members

    assert_equal false, Sth.closed?

    Sth.__send__ :close

    assert_equal true, Sth.closed?

    assert_raises RuntimeError do
      Sth.class_eval do
        member :var2
      end
    end

    assert_equal false, sth.member?(:var2)
  end

end
