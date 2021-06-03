# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Subclass_Class_Macro < Test::Unit::TestCase

  def test_add_members
    klass = Striuct.new :foo do
      add_members :aaa, 'bbb', :ccc
    end

    assert_equal [:foo, :aaa, :bbb, :ccc], klass.members
  end

end
