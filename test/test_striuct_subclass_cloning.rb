$VERBOSE = true
require_relative 'helper'

class TestStriuctCloning < Test::Unit::TestCase

  class Sth < Striuct.new
    member :sth
  end
  
  def setup
    @sth = Sth.new
  end
  
  def test_clone
    sth2 = @sth.dup
    @sth.sth = 1
    assert_equal false, (@sth.sth == sth2.sth)
    
    sth2 = @sth.clone
    @sth.sth = 2
    assert_equal false, (@sth.sth == sth2.sth)
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