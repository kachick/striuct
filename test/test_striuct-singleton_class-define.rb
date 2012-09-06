require_relative 'helper'

class Test_Striuct_Define < Test::Unit::TestCase

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

