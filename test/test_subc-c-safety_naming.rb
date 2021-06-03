# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Subclass_Class_SafetyNaming < Test::Unit::TestCase

  def test_cname?
    klass = Striuct.new
    assert_same false, klass.cname?(BasicObject)
    assert_same false, klass.cname?('m?')
    assert_same false, klass.cname?('__foo__')
    assert_same false, klass.cname?('a b')
    assert_same false, klass.cname?('object_id')
    assert_same false, klass.cname?('to_ary')
    assert_same true, klass.cname?('foo')
    klass.__send__ :set_conflict_management_level, :warning
    assert_same false, klass.cname?('m?')
    assert_same false, klass.cname?('__foo__')
    assert_same false, klass.cname?('a b')
    assert_same false, klass.cname?('object_id')
    assert_same false, klass.cname?('to_ary')
    assert_same true, klass.cname?('foo')
    klass.__send__ :set_conflict_management_level, :struct
    assert_same true, klass.cname?('m?')
    assert_same true, klass.cname?('__foo__')
    assert_same true, klass.cname?('a b')
    assert_same true, klass.cname?('object_id')
    assert_same true, klass.cname?('to_ary')
    assert_same true, klass.cname?('foo')
  end

  def test_protect
    klass = Striuct.new
    assert_raises NameError do
      klass.class_eval do
        member ''
      end
    end

    assert_raises NameError do
      klass.class_eval do
        member :'a b'
      end
    end

    assert_raises NameError do
      klass.class_eval do
        member :__send__
      end
    end

    assert_raises NameError do
      klass.class_eval do
        member :__foo__
      end
    end

    assert_raises NameError do
      klass.class_eval do
        member :m?
      end
    end

    assert_same false, klass.member?('m?')

    klass.class_eval do
      conflict_management :struct do
        member :m?
      end
    end

    assert_same true, klass.member?('m?')
  end

end
