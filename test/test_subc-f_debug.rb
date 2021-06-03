# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Subclass_Debug < Test::Unit::TestCase

  Subclass = Striuct.define do
    member :foo
    member :bar
    alias_member :als_foo, :foo
  end.freeze

  INSTANCE = Subclass.new.freeze

  TYPE_PAIRS = {
    Class: Subclass,
    Instance: INSTANCE
  }.freeze

  [:attributes].each do |callee|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{callee}" do
        assert_same true, reciever.public_methods.include?(callee)
        ret = reciever.public_send(callee)
        assert_instance_of Hash, ret
        assert_equal [:autonyms, :aliases, :conflict_management_level, :attributes_each_autonym], ret.keys
        assert_equal Subclass.autonyms, ret.fetch(:autonyms)
        assert_equal Subclass.aliases, ret.fetch(:aliases)
        assert_equal Subclass.conflict_management_level, ret.fetch(:conflict_management_level)
        assert_equal Subclass.instance_variable_get(:@attributes), ret.fetch(:attributes_each_autonym)

        10.times do
          ret2 = reciever.public_send(callee)
          assert_not_same ret, ret2
          assert_equal ret, ret2
        end
      end
    end
  end

end
