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
    Class: Subclass,
    Instance: INSTANCE
  }.freeze

  [:_autonyms].each do |callee|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{callee}" do
        assert_equal true, reciever.private_methods.include?(callee)
        
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

  [:autonym_for_alias].each do |callee|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{callee}" do
        assert_same true, reciever.public_methods.include?(callee)

        assert_raises NoMethodError, TypeError do
          reciever.public_send(callee, BasicObject.new)
        end

        assert_raises TypeError do
          reciever.public_send(callee, Object.new)
        end
        
        assert_raises NameError do
          reciever.public_send(callee, :foo)
        end

        assert_same :foo, reciever.public_send(callee, :als_foo)
        

        assert_raises NameError do
          reciever.public_send(callee, 'foo')
        end

        assert_same :foo, reciever.public_send(callee, 'als_foo')

        assert_raises TypeError do
          reciever.public_send(callee, 0)
        end

        assert_raises TypeError do
          reciever.public_send(callee, 0.9)
        end

        assert_raises NameError do
          reciever.public_send(callee, :bar)
        end

        assert_raises NameError do
          reciever.public_send(callee, :als_bar)
        end

        assert_raises NameError do
          reciever.public_send(callee, 'bar')
        end

        assert_raises NameError do
          reciever.public_send(callee, 'als_bar')
        end

        assert_raises TypeError do
          reciever.public_send(callee, 1)
        end

        assert_raises TypeError do
          reciever.public_send(callee, 1.9)
        end

        assert_raises NameError do
          reciever.public_send(callee, :none)
        end

        assert_raises NameError do
          reciever.public_send(callee, :als_none)
        end

        assert_raises NameError do
          reciever.public_send(callee, 'none')
        end

        assert_raises NameError do
          reciever.public_send(callee, 'als_none')
        end

        assert_raises TypeError do
          reciever.public_send(callee, 2)
        end

        assert_raises TypeError do
          reciever.public_send(callee, 2.9)
        end
      end
    end
  end

  [:autonym_for_member].each do |callee|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{callee}" do
        assert_same true, reciever.public_methods.include?(callee)

        assert_raises NoMethodError, TypeError do
          reciever.public_send(callee, BasicObject.new)
        end

        assert_raises TypeError do
          reciever.public_send(callee, Object.new)
        end

        assert_same :foo, reciever.public_send(callee, :foo)
        assert_same :foo, reciever.public_send(callee, :als_foo)
        assert_same :foo, reciever.public_send(callee, 'foo')
        assert_same :foo, reciever.public_send(callee, 'als_foo')

        assert_raises TypeError do
          reciever.public_send(callee, 0)
        end

        assert_raises TypeError do
          reciever.public_send(callee, 0.9)
        end

        assert_same :bar, reciever.public_send(callee, :bar)
        
        assert_raises NameError do
          reciever.public_send(callee, :als_bar)
        end

        assert_same :bar, reciever.public_send(callee, 'bar')

        assert_raises NameError do
          reciever.public_send(callee, 'als_bar')
        end

        assert_raises TypeError do
          reciever.public_send(callee, 1)
        end

        assert_raises TypeError do
          reciever.public_send(callee, 1.9)
        end

        assert_raises NameError do
          reciever.public_send(callee, :none)
        end

        assert_raises NameError do
          reciever.public_send(callee, :als_none)
        end

        assert_raises NameError do
          reciever.public_send(callee, 'none')
        end

        assert_raises NameError do
          reciever.public_send(callee, 'als_none')
        end

        assert_raises TypeError do
          reciever.public_send(callee, 2)
        end

        assert_raises TypeError do
          reciever.public_send(callee, 2.9)
        end
      end
    end
  end


  [:autonym_for_index].each do |callee|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{callee}" do
        assert_same true, reciever.public_methods.include?(callee)

        assert_raises NoMethodError, TypeError do
          reciever.public_send(callee, BasicObject.new)
        end

        assert_raises TypeError do
          reciever.public_send(callee, Object.new)
        end

        assert_raises TypeError do
          reciever.public_send(callee, :foo)
        end

        assert_raises TypeError do
          reciever.public_send(callee, :als_foo)
        end

        assert_raises TypeError do
          reciever.public_send(callee, 'foo')
        end

        assert_raises TypeError do
          reciever.public_send(callee, 'als_foo')
        end

        assert_same :foo, reciever.public_send(callee, 0)
        assert_same :foo, reciever.public_send(callee, 0.9)
        assert_same :foo, reciever.public_send(callee, -2)
        assert_same :foo, reciever.public_send(callee, -2.9)

        assert_raises TypeError do
          reciever.public_send(callee, :bar)
        end

        assert_raises TypeError do
          reciever.public_send(callee, :als_bar)
        end

        assert_raises TypeError do
          reciever.public_send(callee, 'bar')
        end

        assert_raises TypeError do
          reciever.public_send(callee, 'als_bar')
        end

        assert_same :bar, reciever.public_send(callee, 1)
        assert_same :bar, reciever.public_send(callee, 1.9)
        assert_same :bar, reciever.public_send(callee, -1)
        assert_same :bar, reciever.public_send(callee, -1.9)

        assert_raises TypeError do
          reciever.public_send(callee, :none)
        end

        assert_raises TypeError do
          reciever.public_send(callee, :als_none)
        end

        assert_raises TypeError do
          reciever.public_send(callee, 'none')
        end

        assert_raises TypeError do
          reciever.public_send(callee, 'als_none')
        end

        assert_raises IndexError do
          reciever.public_send(callee, 2)
        end

        assert_raises IndexError do
          reciever.public_send(callee, 2.9)
        end

        assert_raises IndexError do
          reciever.public_send(callee, -3)
        end

        assert_raises IndexError do
          reciever.public_send(callee, -3.9)
        end
      end
    end
  end

  [:autonym_for_key].each do |callee|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{callee}" do
        assert_same true, reciever.public_methods.include?(callee)

        assert_raises KeyError do
          reciever.public_send(callee, BasicObject.new)
        end

        assert_raises KeyError do
          reciever.public_send(callee, Object.new)
        end

        assert_same :foo, reciever.public_send(callee, :foo)
        assert_same :foo, reciever.public_send(callee, :als_foo)
        assert_same :foo, reciever.public_send(callee, 'foo')
        assert_same :foo, reciever.public_send(callee, 'als_foo')
        assert_same :foo, reciever.public_send(callee, 0)
        assert_same :foo, reciever.public_send(callee, 0.9)
        assert_same :foo, reciever.public_send(callee, -2)
        assert_same :foo, reciever.public_send(callee, -2.9)

        assert_same :bar, reciever.public_send(callee, :bar)
        
        assert_raises KeyError do
          assert_same :bar, reciever.public_send(callee, :als_bar)
        end

        assert_same :bar, reciever.public_send(callee, 'bar')

        assert_raises KeyError do
          assert_same :bar, reciever.public_send(callee, 'als_bar')
        end

        assert_same :bar, reciever.public_send(callee, 1)
        assert_same :bar, reciever.public_send(callee, 1.9)
        assert_same :bar, reciever.public_send(callee, -1)
        assert_same :bar, reciever.public_send(callee, -1.9)

        assert_raises KeyError do
          reciever.public_send(callee, :none)
        end

        assert_raises KeyError do
          reciever.public_send(callee, :als_none)
        end

        assert_raises KeyError do
          reciever.public_send(callee, 'none')
        end

        assert_raises KeyError do
          reciever.public_send(callee, 'als_none')
        end

        assert_raises KeyError do
          reciever.public_send(callee, 2)
        end

        assert_raises KeyError do
          reciever.public_send(callee, 2.9)
        end

        assert_raises KeyError do
          reciever.public_send(callee, -3)
        end

        assert_raises KeyError do
          reciever.public_send(callee, -3.9)
        end
      end
    end
  end

  [:aliases_for_autonym].each do |callee|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{callee}" do
        assert_same true, reciever.public_methods.include?(callee)

        assert_raises NoMethodError, TypeError do
          reciever.public_send(callee, BasicObject.new)
        end

        assert_raises TypeError do
          reciever.public_send(callee, Object.new)
        end
       
        assert_equal [:als_foo], reciever.public_send(callee, :foo)
        
        assert_raises NameError do
          reciever.public_send(callee, :als_foo)
        end

        assert_equal [:als_foo], reciever.public_send(callee, 'foo')

        assert_raises NameError do
          reciever.public_send(callee, 'als_foo')
        end

        assert_raises TypeError do
          reciever.public_send(callee, 0)
        end

        assert_raises TypeError do
          reciever.public_send(callee, 0.9)
        end

        assert_raises NameError do
          reciever.public_send(callee, :bar)
        end

        assert_raises NameError do
          reciever.public_send(callee, :als_bar)
        end

        assert_raises NameError do
          reciever.public_send(callee, 'bar')
        end

        assert_raises NameError do
          reciever.public_send(callee, 'als_bar')
        end

        assert_raises TypeError do
          reciever.public_send(callee, 1)
        end

        assert_raises TypeError do
          reciever.public_send(callee, 1.9)
        end

        assert_raises NameError do
          reciever.public_send(callee, :none)
        end

        assert_raises NameError do
          reciever.public_send(callee, :als_none)
        end

        assert_raises NameError do
          reciever.public_send(callee, 'none')
        end

        assert_raises NameError do
          reciever.public_send(callee, 'als_none')
        end

        assert_raises TypeError do
          reciever.public_send(callee, 2)
        end

        assert_raises TypeError do
          reciever.public_send(callee, 2.9)
        end        
      end
    end
  end

  aliase_for_autonym_ext_pairs = {}.tap {|h|
    h[:Class] = Striuct.define do
      member :foo
      alias_member :als1_foo, :foo
      member :bar
      alias_member :als1_bar, :bar
      alias_member :als2_foo, :foo
      alias_member :als3_foo, :foo
      member :xyz
    end.freeze

    h[:Instance] = h[:Class].new.freeze 
  }.freeze

  [:aliases_for_autonym].each do |callee|
    aliase_for_autonym_ext_pairs.each_pair do |type, reciever|
      define_method :"test_#{type}_#{callee}_2" do
        assert_equal [:als1_foo, :als2_foo, :als3_foo], reciever.public_send(callee, 'foo')
        assert_equal [:als1_bar], reciever.public_send(callee, 'bar')
        assert_raises NameError do
          reciever.public_send(callee, 'xyz')
        end
      end
    end
  end

end
