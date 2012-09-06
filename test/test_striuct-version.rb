require_relative 'helper'

class Test_Striuct_Version < Test::Unit::TestCase

  def test_const_version
    assert_kind_of String, Striuct::VERSION
    assert(/\A\d+\.\d+\.\d+(\.\w+)?\z/ =~ Striuct::VERSION)
    assert_equal true, Striuct::VERSION.frozen?
  end

end