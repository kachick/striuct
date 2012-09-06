require_relative 'helper'

class TestStriuctDefine < Test::Unit::TestCase

  def test_define
    assert_raises RuntimeError do
      Striuct.define do
      end
    end
    
    klass = Striuct.define do
      member :foo
    end

    assert_equal true, klass.closed?
  end

end

