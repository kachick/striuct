require_relative 'helper'

class Test_Striuct_Subclass_Name < Test::Unit::TestCase
  
  # for peep
  origin_autonyms = nil
  origin_aliases = nil

  Subclass = Striuct.define do
    origin_autonyms = @autonyms
    origin_aliases  = @aliases

    member :foo
    member :bar
    alias_member :als_foo, :foo

    close_member
  end.freeze

  INSTANCE = Subclass.new.freeze
  
  TYPE_PAIRS = {
    class: Subclass,
    instance: INSTANCE
  }.freeze

  [:_autonyms].each do |callee|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{callee}" do
        assert_same true, reciever.private_methods.include?(callee)
        
        assert_raises NoMethodError do
          reciever.public_send(callee)
        end
        
        assert_same origin_autonyms, reciever.__send__(callee)
      end
    end
  end

  [:autonyms, :members].each do |callee|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{callee}" do
        assert_same true, reciever.public_methods.include?(callee)
        ret = reciever.public_send(callee)
        assert_not_same origin_autonyms, ret
        assert_equal origin_autonyms, ret
        
        10.times do
          ret2 = reciever.public_send(callee)
          assert_not_same ret, ret2
          assert_equal ret, ret2
        end
      end
    end
  end
  
  [:all_members].each do |callee|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{callee}" do
        assert_same true, reciever.public_methods.include?(callee)
        ret = reciever.public_send(callee)
        assert_equal [*origin_autonyms, :als_foo], ret
        
        10.times do
          ret2 = reciever.public_send(callee)
          assert_not_same ret, ret2
          assert_equal ret, ret2
        end
      end
    end
  end
  
  [:aliases].each do |callee|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{callee}" do
        assert_same true, reciever.public_methods.include?(callee)
        ret = reciever.public_send(callee)
        assert_not_same(origin_aliases, ret)
        assert_equal({:als_foo => :foo}, ret)
        
        10.times do
          ret2 = reciever.public_send(callee)
          assert_not_same(origin_aliases, ret2)
          assert_not_same ret, ret2
          assert_equal ret, ret2
        end
      end
    end
  end

end