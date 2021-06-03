# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Version < Test::Unit::TestCase

  def test_const_version_of_own
    assert_same false, Striuct.const_defined?(:VERSION, false)
  end

  def test_const_version_of_dependencies
    assert_same false, Striuct.const_defined?(:VERSION, true)
  end

end
