require_relative 'helper'

class Test_Striuct_Subclass_Instance_Cast < Test::Unit::TestCase

  Sth = Striuct.new :foo, :bar, :hoge
  
  def test_to_h
    sth = Sth.new
    assert_equal({foo: nil, bar: nil, hoge: nil}, sth.to_h)
    assert_equal({foo: nil, bar: nil, hoge: nil}, sth.to_h(true))
    assert_equal({}, sth.to_h(false))

    sth.bar = :BAR
    assert_equal({foo: nil, bar: :BAR, hoge: nil}, sth.to_h)
    assert_equal({foo: nil, bar: :BAR, hoge: nil}, sth.to_h(true))
    assert_equal({bar: :BAR}, sth.to_h(false))
  end

  def test_to_a
    sth = Sth.new
    assert_equal([nil, nil, nil], sth.to_a)

    sth.bar = :BAR
    assert_equal([nil, :BAR, nil], sth.to_a)
  end

end
