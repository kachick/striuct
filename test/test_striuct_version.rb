require_relative 'helper'

class TestStriuctVersion < Test::Unit::TestCase

  def test_const_version
    assert_equal true, Striuct::VERSION.frozen?
  end

end