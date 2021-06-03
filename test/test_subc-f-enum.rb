# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Subclass_Enum < Test::Unit::TestCase

  class Subclass < Striuct
    member :foo
    member :bar

    close_member
  end.freeze

  FOO = 'Fooo! :)'.freeze
  BAR = 'bar :('.freeze
  INSTANCE = Subclass.new(FOO, BAR).freeze

  TYPE_PAIRS = {
    class: Subclass,
    instance: INSTANCE
  }.freeze

  [:each_autonym, :each_member].each do |callee|
    TYPE_PAIRS.each_pair do |type, receiver|
      define_method :"test_#{type}_#{callee}" do
        assert_same(receiver, receiver.public_send(callee) {})

        enum = receiver.public_send(callee)
        assert_instance_of Enumerator, enum
        assert_equal 2, enum.size
        assert_same :foo, enum.next
        assert_same :bar, enum.next
        assert_raises StopIteration do
          enum.next
        end
      end
    end
  end

  [:each_index].each do |callee|
    TYPE_PAIRS.each_pair do |type, receiver|
      define_method :"test_#{type}_#{callee}" do
        assert_same(receiver, receiver.public_send(callee) {})

        enum = receiver.public_send(callee)
        assert_instance_of Enumerator, enum
        assert_equal 2, enum.size
        assert_same 0, enum.next
        assert_same 1, enum.next
        assert_raises StopIteration do
          enum.next
        end
      end
    end
  end

  [:each_autonym_with_index, :each_member_with_index].each do |callee|
    TYPE_PAIRS.each_pair do |type, receiver|
      define_method :"test_#{type}_#{callee}" do
        assert_same(receiver, receiver.public_send(callee) {})

        enum = receiver.public_send(callee)
        assert_instance_of Enumerator, enum
        assert_equal 2, enum.size
        assert_equal [:foo, 0], enum.next
        assert_equal [:bar, 1], enum.next
        assert_raises StopIteration do
          enum.next
        end
      end
    end
  end

  [:each_value, :each].each do |callee|
    {instance: INSTANCE}.each_pair do |type, receiver|
      define_method :"test_#{type}_#{callee}" do
        assert_same(receiver, receiver.public_send(callee) {})

        enum = receiver.public_send(callee)
        assert_instance_of Enumerator, enum
        assert_equal 2, enum.size
        assert_same FOO, enum.next
        assert_same BAR, enum.next
        assert_raises StopIteration do
          enum.next
        end
      end
    end
  end

  [:each_value_with_index, :each_with_index].each do |callee|
    {instance: INSTANCE}.each_pair do |type, receiver|
      define_method :"test_#{type}_#{callee}" do
        assert_same(receiver, receiver.public_send(callee) {})

        enum = receiver.public_send(callee)
        assert_instance_of Enumerator, enum
        assert_equal 2, enum.size
        assert_equal [FOO, 0], ret = enum.next
        assert_same FOO, ret.first
        assert_equal [BAR, 1], ret = enum.next
        assert_same BAR, ret.first
        assert_raises StopIteration do
          enum.next
        end
      end
    end
  end

  [:each_pair].each do |callee|
    {instance: INSTANCE}.each_pair do |type, receiver|
      define_method :"test_#{type}_#{callee}" do
        assert_same(receiver, receiver.public_send(callee) {})

        enum = receiver.public_send(callee)
        assert_instance_of Enumerator, enum
        assert_equal 2, enum.size
        assert_equal [:foo, FOO], ret = enum.next
        assert_same FOO, ret.last
        assert_equal [:bar, BAR], ret = enum.next
        assert_same BAR, ret.last
        assert_raises StopIteration do
          enum.next
        end
      end
    end
  end

  [:each_pair_with_index].each do |callee|
    {instance: INSTANCE}.each_pair do |type, receiver|
      define_method :"test_#{type}_#{callee}" do
        assert_same(receiver, receiver.public_send(callee) {})

        enum = receiver.public_send(callee)
        assert_instance_of Enumerator, enum
        assert_equal 2, enum.size
        assert_equal [:foo, FOO, 0], ret = enum.next
        assert_same FOO, ret[1]
        assert_equal [:bar, BAR, 1], ret = enum.next
        assert_same BAR, ret[1]
        assert_raises StopIteration do
          enum.next
        end
      end
    end

    def test_modified_members_enum_size
      klass = Striuct.new do
        member :foo
      end
      cenum = klass.each_autonym
      ienum = klass.new.each_autonym
      assert_equal 1, cenum.size
      assert_equal 1, ienum.size
      klass.send :member, :bar
      assert_equal 2, cenum.size
      assert_equal 2, ienum.size
    end
  end

end
