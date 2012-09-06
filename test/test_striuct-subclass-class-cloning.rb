require_relative 'helper'

class TestStriuctClassCloning < Test::Unit::TestCase

  class Sth < Striuct.new
    member :sth
  end

  def test_class_dup
    klass = Sth.dup
    Sth.__send__ :member, :dummy1
    assert_equal false, klass.member?(:dummy1)
  end
  
  def test_class_clone
    klass = Sth.clone
    Sth.__send__ :member, :dummy2
    assert_equal false, klass.member?(:dummy2)
  end

end