# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Subclass_Must < Test::Unit::TestCase

  Sth = Striuct.define do
    member :foo, ANYTHING(), must: false
    member :bar, ANYTHING(), must: true
    member :baz
  end

  def test_must
    assert_raises(Striuct::InvalidOperationError) do
      Sth.new :foo
    end

    assert_raises(Striuct::InvalidOperationError) do
      Sth.new foo: :foo, baz: :baz
    end

    sth = Sth.new :foo, :bar, :baz
    assert_instance_of(Sth, sth)

    assert_raises(Striuct::InvalidOperationError) do
      sth.unassign :bar
    end

    assert_nil(sth.bar = nil)
  end

end
