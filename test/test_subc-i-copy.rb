# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Subclass_Instance_Copy < Test::Unit::TestCase

  class Sth < Striuct.new
    member :sth
  end

  def test_dup
    sth = Sth.new
    sth2 = sth.dup
    sth.sth = 1
    assert_equal false, (sth.sth == sth2.sth)
  end

  def test_clone
    sth = Sth.new
    sth2 = sth.clone
    sth.sth = 2
    assert_equal false, (sth.sth == sth2.sth)
  end

end
