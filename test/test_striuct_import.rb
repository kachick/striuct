$VERBOSE = true
require File.dirname(__FILE__) + '/test_helper_import.rb'


class TestStriuctStructExtention < Test::Unit::TestCase
  Sth = Struct.new :age
  Sth2 = Sth.to_strict

  def test_eigen_boolean
    assert_equal true, Sth.member?(:age)
    assert_equal false, Sth.conditionable?(BasicObject.new)
    assert_equal false, Sth.restrict?(:age)
    assert_equal true, Sth.accept?(:age, 'String')
    assert_equal false, Sth.has_default?(:age)
    assert_equal true, Sth.cname?(:age)
    assert_equal false, Sth.cname?(Object.new)
  end

  def test_eigen_actions
    assert_equal({}, Sth.conditions)
    assert_equal({}, Sth.procedures)
    assert_equal({}, Sth.defaults)
    r = Sth.define{|o|o.age = 'Something'}
    assert_kind_of Sth, r
    assert_equal 'Something', r.age
    assert_equal StrictStruct, Sth2.superclass
    assert_equal Sth.members, Sth2.members
  end

  def test_instance_boolean
    sth = Sth.new
    assert_equal false, sth.strict?
    assert_equal false, sth.secure?
    assert_equal false, sth.lock?
    assert_equal false, sth.assign?(:age)
    sth.age = 'Something'
    assert_equal true, sth.assign?(:age)
  end
end