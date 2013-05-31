require_relative 'helper'

class Test_Striuct_Subclass_BasicPredicate < Test::Unit::TestCase

  class Subclass < Striuct
    member :foo    
    member :bar
    alias_member :aliased, :bar
    close_member
  end.freeze

  INSTANCE = Subclass.new.freeze
  
  TYPE_PAIRS = {
    class: Subclass,
    instance: INSTANCE
  }.freeze

  [:autonym?, :has_autonym?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same true, reciever.public_send(predicate, :foo)
        assert_same true, reciever.public_send(predicate, :bar)
        assert_same false, reciever.public_send(predicate, :aliased)
        assert_same false, reciever.public_send(predicate, :xyz)
        assert_same false, reciever.public_send(predicate, 1)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
        assert_same true, reciever.public_send(predicate, 'foo')
        assert_same true, reciever.public_send(predicate, 'bar')
        assert_same false, reciever.public_send(predicate, 'aliased')
        assert_same false, reciever.public_send(predicate, 'xyz')
      end
    end
  end

  [:alias?, :has_alias?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same false, reciever.public_send(predicate, :foo)
        assert_same false, reciever.public_send(predicate, :bar)
        assert_same true, reciever.public_send(predicate, :aliased)
        assert_same false, reciever.public_send(predicate, :xyz)
        assert_same false, reciever.public_send(predicate, 1)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
        assert_same false, reciever.public_send(predicate, 'foo')
        assert_same false, reciever.public_send(predicate, 'bar')
        assert_same true, reciever.public_send(predicate, 'aliased')
        assert_same false, reciever.public_send(predicate, 'xyz')
      end
    end
  end

  [:member?, :has_member?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same true, reciever.public_send(predicate, :foo)
        assert_same true, reciever.public_send(predicate, :bar)
        assert_same true, reciever.public_send(predicate, :aliased)
        assert_same false, reciever.public_send(predicate, :xyz)
        assert_same false, reciever.public_send(predicate, 1)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
        assert_same true, reciever.public_send(predicate, 'foo')
        assert_same true, reciever.public_send(predicate, 'bar')
        assert_same true, reciever.public_send(predicate, 'aliased')
        assert_same false, reciever.public_send(predicate, 'xyz')
      end
    end
  end

  [:index?, :has_index?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same true, reciever.public_send(predicate, 0)
        assert_same true, reciever.public_send(predicate, 1)
        assert_same false, reciever.public_send(predicate, 2)
        assert_same false, reciever.public_send(predicate, 99 * 99)
        assert_same true, reciever.public_send(predicate, -1)
        assert_same true, reciever.public_send(predicate, -2)
        assert_same false, reciever.public_send(predicate, -3)
        assert_same false, reciever.public_send(predicate, -(99 * 99))
        assert_same true, reciever.public_send(predicate, 0.1)
        assert_same true, reciever.public_send(predicate, 1.9)
        assert_same false, reciever.public_send(predicate, '1')
        assert_same false, reciever.public_send(predicate, :foo)
        assert_same false, reciever.public_send(predicate, :bar)
        assert_same false, reciever.public_send(predicate, :aliased)
        assert_same false, reciever.public_send(predicate, :xyz)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
        assert_same false, reciever.public_send(predicate, 'foo')
        assert_same false, reciever.public_send(predicate, 'bar')
        assert_same false, reciever.public_send(predicate, 'aliased')
        assert_same false, reciever.public_send(predicate, 'xyz')
      end
    end
  end

  [:key?, :has_key?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same true, reciever.public_send(predicate, 0)
        assert_same true, reciever.public_send(predicate, 1)
        assert_same false, reciever.public_send(predicate, 2)
        assert_same false, reciever.public_send(predicate, 99 * 99)
        assert_same true, reciever.public_send(predicate, -1)
        assert_same true, reciever.public_send(predicate, -2)
        assert_same false, reciever.public_send(predicate, -3)
        assert_same false, reciever.public_send(predicate, -(99 * 99))
        assert_same true, reciever.public_send(predicate, 0.1)
        assert_same true, reciever.public_send(predicate, 1.9)
        assert_same false, reciever.public_send(predicate, '1')
        assert_same true, reciever.public_send(predicate, :foo)
        assert_same true, reciever.public_send(predicate, :bar)
        assert_same true, reciever.public_send(predicate, :aliased)
        assert_same false, reciever.public_send(predicate, :xyz)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
        assert_same true, reciever.public_send(predicate, 'foo')
        assert_same true, reciever.public_send(predicate, 'bar')
        assert_same true, reciever.public_send(predicate, 'aliased')
        assert_same false, reciever.public_send(predicate, 'xyz')
      end
    end
  end

  [:with_aliases?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same false, reciever.public_send(predicate, :foo)
        assert_same true, reciever.public_send(predicate, :bar)
        assert_same false, reciever.public_send(predicate, :aliased)
        assert_same false, reciever.public_send(predicate, :xyz)
        assert_same false, reciever.public_send(predicate, 1)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
        assert_same false, reciever.public_send(predicate, 'foo')
        assert_same true, reciever.public_send(predicate, 'bar')
        assert_same false, reciever.public_send(predicate, 'aliased')
        assert_same false, reciever.public_send(predicate, 'xyz')
      end
    end
  end

end


class Test_Striuct_Subclass_Predicate_Default < Test::Unit::TestCase

  class Subclass < Striuct
    member :foo    
    member :val, BasicObject, default: 'DEFAULT'
    
    conflict_management :struct do
      member :lazy, BasicObject, default_proc: ->{}
    end
    
    alias_member :als_foo, :foo
    alias_member :als_val, :val
    alias_member :als_lazy, :lazy
    close_member
  end.freeze

  INSTANCE = Subclass.new.freeze
  
  TYPE_PAIRS = {
    class: Subclass,
    instance: INSTANCE
  }.freeze

  [:with_default?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same false, reciever.public_send(predicate, :foo)
        assert_same false, reciever.public_send(predicate, :als_foo)
        assert_same false, reciever.public_send(predicate, 'foo')
        assert_same false, reciever.public_send(predicate, 'als_foo')
        assert_same false, reciever.public_send(predicate, 0)
        assert_same false, reciever.public_send(predicate, 0.9)
        
        assert_same true, reciever.public_send(predicate, :val)
        assert_same true, reciever.public_send(predicate, :als_val)
        assert_same true, reciever.public_send(predicate, 'val')
        assert_same true, reciever.public_send(predicate, 'als_val')
        assert_same true, reciever.public_send(predicate, 1)
        assert_same true, reciever.public_send(predicate, 1.9)
        
        assert_same true, reciever.public_send(predicate, :lazy)
        assert_same true, reciever.public_send(predicate, :als_lazy)
        assert_same true, reciever.public_send(predicate, 'lazy')
        assert_same true, reciever.public_send(predicate, 'als_lazy')
        assert_same true, reciever.public_send(predicate, 2)
        assert_same true, reciever.public_send(predicate, 2.9)
        
        assert_same false, reciever.public_send(predicate, :none)
        assert_same false, reciever.public_send(predicate, 'none')
        assert_same false, reciever.public_send(predicate, 3)
        assert_same false, reciever.public_send(predicate, 3.9)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
      end
    end
  end

end

class Test_Striuct_Subclass_Predicate_Adjuster < Test::Unit::TestCase

  class Subclass < Striuct
    member :no_with
    alias_member :als_no_with, :no_with
    member :with do |_|; end
    alias_member :als_with, :with
    member :cond_with, BasicObject do |_|; end
    alias_member :als_cond_with, :cond_with

    close_member
  end.freeze

  INSTANCE = Subclass.new.freeze
  
  TYPE_PAIRS = {
    class: Subclass,
    instance: INSTANCE
  }.freeze

  [:with_adjuster?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same false, reciever.public_send(predicate, :no_with)
        assert_same false, reciever.public_send(predicate, :als_no_with)
        assert_same false, reciever.public_send(predicate, 'no_with')
        assert_same false, reciever.public_send(predicate, 'als_no_with')
        assert_same false, reciever.public_send(predicate, 0)
        assert_same false, reciever.public_send(predicate, 0.9)
        
        assert_same true, reciever.public_send(predicate, :with)
        assert_same true, reciever.public_send(predicate, :als_with)
        assert_same true, reciever.public_send(predicate, 'with')
        assert_same true, reciever.public_send(predicate, 'als_with')
        assert_same true, reciever.public_send(predicate, 1)
        assert_same true, reciever.public_send(predicate, 1.9)
        
        assert_same true, reciever.public_send(predicate, :cond_with)
        assert_same true, reciever.public_send(predicate, :als_cond_with)
        assert_same true, reciever.public_send(predicate, 'cond_with')
        assert_same true, reciever.public_send(predicate, 'als_cond_with')
        assert_same true, reciever.public_send(predicate, 2)
        assert_same true, reciever.public_send(predicate, 2.9)
        
        assert_same false, reciever.public_send(predicate, :none)
        assert_same false, reciever.public_send(predicate, 'none')
        assert_same false, reciever.public_send(predicate, 3)
        assert_same false, reciever.public_send(predicate, 3.9)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
      end
    end
  end

end

class Test_Striuct_Subclass_Predicate_Condition < Test::Unit::TestCase

  class Subclass < Striuct
    member :no_with
    alias_member :als_no_with, :no_with
    member :with, nil
    alias_member :als_with, :with
    member :with_any, BasicObject
    alias_member :als_with_any, :with_any
    member :adj_with, nil do |_|; end
    alias_member :als_adj_with, :adj_with

    close_member
  end.freeze

  INSTANCE = Subclass.new.freeze
  
  TYPE_PAIRS = {
    class: Subclass,
    instance: INSTANCE
  }.freeze

  [:with_condition?, :restrict?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same false, reciever.public_send(predicate, :no_with)
        assert_same false, reciever.public_send(predicate, :als_no_with)
        assert_same false, reciever.public_send(predicate, 'no_with')
        assert_same false, reciever.public_send(predicate, 'als_no_with')
        assert_same false, reciever.public_send(predicate, 0)
        assert_same false, reciever.public_send(predicate, 0.9)
        
        assert_same true, reciever.public_send(predicate, :with)
        assert_same true, reciever.public_send(predicate, :als_with)
        assert_same true, reciever.public_send(predicate, 'with')
        assert_same true, reciever.public_send(predicate, 'als_with')
        assert_same true, reciever.public_send(predicate, 1)
        assert_same true, reciever.public_send(predicate, 1.9)

        assert_same false, reciever.public_send(predicate, :with_any)
        assert_same false, reciever.public_send(predicate, :als_with_any)
        assert_same false, reciever.public_send(predicate, 'with_any')
        assert_same false, reciever.public_send(predicate, 'als_with_any')
        assert_same false, reciever.public_send(predicate, 2)
        assert_same false, reciever.public_send(predicate, 2.9)
  
        assert_same true, reciever.public_send(predicate, :adj_with)
        assert_same true, reciever.public_send(predicate, :als_adj_with)
        assert_same true, reciever.public_send(predicate, 'adj_with')
        assert_same true, reciever.public_send(predicate, 'als_adj_with')
        assert_same true, reciever.public_send(predicate, 3)
        assert_same true, reciever.public_send(predicate, 3.9)
        
        assert_same false, reciever.public_send(predicate, :none)
        assert_same false, reciever.public_send(predicate, 'none')
        assert_same false, reciever.public_send(predicate, 4)
        assert_same false, reciever.public_send(predicate, 4.9)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
      end
    end
  end

end

class Test_Striuct_Subclass_Predicate_InferenceValidation < Test::Unit::TestCase

  class Subclass < Striuct
    member :no_with
    alias_member :als_no_with, :no_with
    member :with, nil, inference: true
    alias_member :als_with, :with
    member :with_any, BasicObject, inference: true
    alias_member :als_with_any, :with_any
    member :adj_with, nil, inference: true do |_|; end
    alias_member :als_adj_with, :adj_with

    close_member
  end.freeze

  INSTANCE = Subclass.new.freeze
  
  TYPE_PAIRS = {
    class: Subclass,
    instance: INSTANCE
  }.freeze

  [:with_inference?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same false, reciever.public_send(predicate, :no_with)
        assert_same false, reciever.public_send(predicate, :als_no_with)
        assert_same false, reciever.public_send(predicate, 'no_with')
        assert_same false, reciever.public_send(predicate, 'als_no_with')
        assert_same false, reciever.public_send(predicate, 0)
        assert_same false, reciever.public_send(predicate, 0.9)
        
        assert_same true, reciever.public_send(predicate, :with)
        assert_same true, reciever.public_send(predicate, :als_with)
        assert_same true, reciever.public_send(predicate, 'with')
        assert_same true, reciever.public_send(predicate, 'als_with')
        assert_same true, reciever.public_send(predicate, 1)
        assert_same true, reciever.public_send(predicate, 1.9)

        assert_same true, reciever.public_send(predicate, :with_any)
        assert_same true, reciever.public_send(predicate, :als_with_any)
        assert_same true, reciever.public_send(predicate, 'with_any')
        assert_same true, reciever.public_send(predicate, 'als_with_any')
        assert_same true, reciever.public_send(predicate, 2)
        assert_same true, reciever.public_send(predicate, 2.9)

        assert_same true, reciever.public_send(predicate, :adj_with)
        assert_same true, reciever.public_send(predicate, :als_adj_with)
        assert_same true, reciever.public_send(predicate, 'adj_with')
        assert_same true, reciever.public_send(predicate, 'als_adj_with')
        assert_same true, reciever.public_send(predicate, 3)
        assert_same true, reciever.public_send(predicate, 3.9)
        
        assert_same false, reciever.public_send(predicate, :none)
        assert_same false, reciever.public_send(predicate, 'none')
        assert_same false, reciever.public_send(predicate, 4)
        assert_same false, reciever.public_send(predicate, 4.9)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
      end
    end
  end

end


class Test_Striuct_Subclass_Predicate_HookTiming_Setter_Enable < Test::Unit::TestCase

  class Subclass < Striuct
    member :no_with
    alias_member :als_no_with, :no_with
    member :with, nil, setter_validation: true
    alias_member :als_with, :with
    member :with_any, BasicObject, writer_validation: true
    alias_member :als_with_any, :with_any
    member :adj_with, nil, writer_validation: true do |_|; end
    alias_member :als_adj_with, :adj_with

    close_member
  end.freeze

  INSTANCE = Subclass.new.freeze
  
  TYPE_PAIRS = {
    class: Subclass,
    instance: INSTANCE
  }.freeze

  [:with_safety_setter?, :with_safety_writer?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same true, reciever.public_send(predicate, :no_with)
        assert_same true, reciever.public_send(predicate, :als_no_with)
        assert_same true, reciever.public_send(predicate, 'no_with')
        assert_same true, reciever.public_send(predicate, 'als_no_with')
        assert_same true, reciever.public_send(predicate, 0)
        assert_same true, reciever.public_send(predicate, 0.9)
        
        assert_same true, reciever.public_send(predicate, :with)
        assert_same true, reciever.public_send(predicate, :als_with)
        assert_same true, reciever.public_send(predicate, 'with')
        assert_same true, reciever.public_send(predicate, 'als_with')
        assert_same true, reciever.public_send(predicate, 1)
        assert_same true, reciever.public_send(predicate, 1.9)

        assert_same true, reciever.public_send(predicate, :with_any)
        assert_same true, reciever.public_send(predicate, :als_with_any)
        assert_same true, reciever.public_send(predicate, 'with_any')
        assert_same true, reciever.public_send(predicate, 'als_with_any')
        assert_same true, reciever.public_send(predicate, 2)
        assert_same true, reciever.public_send(predicate, 2.9)

        assert_same true, reciever.public_send(predicate, :adj_with)
        assert_same true, reciever.public_send(predicate, :als_adj_with)
        assert_same true, reciever.public_send(predicate, 'adj_with')
        assert_same true, reciever.public_send(predicate, 'als_adj_with')
        assert_same true, reciever.public_send(predicate, 3)
        assert_same true, reciever.public_send(predicate, 3.9)
        
        assert_same false, reciever.public_send(predicate, :none)
        assert_same false, reciever.public_send(predicate, 'none')
        assert_same false, reciever.public_send(predicate, 4)
        assert_same false, reciever.public_send(predicate, 4.9)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
      end
    end
  end

end

class Test_Striuct_Subclass_Predicate_HookTiming_Setter_Disable < Test::Unit::TestCase

  class Subclass < Striuct
    member :no_with
    alias_member :als_no_with, :no_with
    
    member :with, nil, setter_validation: false
    alias_member :als_with, :with
    
    member :with_any, BasicObject, writer_validation: false
    alias_member :als_with_any, :with_any
    
    member :adj_with, nil, writer_validation: false do |_|; end
    alias_member :als_adj_with, :adj_with

    close_member
  end.freeze

  INSTANCE = Subclass.new.freeze
  
  TYPE_PAIRS = {
    class: Subclass,
    instance: INSTANCE
  }.freeze

  [:with_safety_setter?, :with_safety_writer?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same true, reciever.public_send(predicate, :no_with)
        assert_same true, reciever.public_send(predicate, :als_no_with)
        assert_same true, reciever.public_send(predicate, 'no_with')
        assert_same true, reciever.public_send(predicate, 'als_no_with')
        assert_same true, reciever.public_send(predicate, 0)
        assert_same true, reciever.public_send(predicate, 0.9)
        
        assert_same false, reciever.public_send(predicate, :with)
        assert_same false, reciever.public_send(predicate, :als_with)
        assert_same false, reciever.public_send(predicate, 'with')
        assert_same false, reciever.public_send(predicate, 'als_with')
        assert_same false, reciever.public_send(predicate, 1)
        assert_same false, reciever.public_send(predicate, 1.9)

        assert_same false, reciever.public_send(predicate, :with_any)
        assert_same false, reciever.public_send(predicate, :als_with_any)
        assert_same false, reciever.public_send(predicate, 'with_any')
        assert_same false, reciever.public_send(predicate, 'als_with_any')
        assert_same false, reciever.public_send(predicate, 2)
        assert_same false, reciever.public_send(predicate, 2.9)

        assert_same false, reciever.public_send(predicate, :adj_with)
        assert_same false, reciever.public_send(predicate, :als_adj_with)
        assert_same false, reciever.public_send(predicate, 'adj_with')
        assert_same false, reciever.public_send(predicate, 'als_adj_with')
        assert_same false, reciever.public_send(predicate, 3)
        assert_same false, reciever.public_send(predicate, 3.9)
        
        assert_same false, reciever.public_send(predicate, :none)
        assert_same false, reciever.public_send(predicate, 'none')
        assert_same false, reciever.public_send(predicate, 4)
        assert_same false, reciever.public_send(predicate, 4.9)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
      end
    end
  end

end


class Test_Striuct_Subclass_Predicate_HookTiming_Getter_Enable < Test::Unit::TestCase

  class Subclass < Striuct
    member :no_with
    alias_member :als_no_with, :no_with
    member :with, nil, getter_validation: true
    alias_member :als_with, :with
    member :with_any, BasicObject, reader_validation: true
    alias_member :als_with_any, :with_any
    member :adj_with, nil, reader_validation: true do |_|; end
    alias_member :als_adj_with, :adj_with

    close_member
  end.freeze

  INSTANCE = Subclass.new.freeze
  
  TYPE_PAIRS = {
    class: Subclass,
    instance: INSTANCE
  }.freeze

  [:with_safety_getter?, :with_safety_reader?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same false, reciever.public_send(predicate, :no_with)
        assert_same false, reciever.public_send(predicate, :als_no_with)
        assert_same false, reciever.public_send(predicate, 'no_with')
        assert_same false, reciever.public_send(predicate, 'als_no_with')
        assert_same false, reciever.public_send(predicate, 0)
        assert_same false, reciever.public_send(predicate, 0.9)
        
        assert_same true, reciever.public_send(predicate, :with)
        assert_same true, reciever.public_send(predicate, :als_with)
        assert_same true, reciever.public_send(predicate, 'with')
        assert_same true, reciever.public_send(predicate, 'als_with')
        assert_same true, reciever.public_send(predicate, 1)
        assert_same true, reciever.public_send(predicate, 1.9)

        assert_same true, reciever.public_send(predicate, :with_any)
        assert_same true, reciever.public_send(predicate, :als_with_any)
        assert_same true, reciever.public_send(predicate, 'with_any')
        assert_same true, reciever.public_send(predicate, 'als_with_any')
        assert_same true, reciever.public_send(predicate, 2)
        assert_same true, reciever.public_send(predicate, 2.9)

        assert_same true, reciever.public_send(predicate, :adj_with)
        assert_same true, reciever.public_send(predicate, :als_adj_with)
        assert_same true, reciever.public_send(predicate, 'adj_with')
        assert_same true, reciever.public_send(predicate, 'als_adj_with')
        assert_same true, reciever.public_send(predicate, 3)
        assert_same true, reciever.public_send(predicate, 3.9)
        
        assert_same false, reciever.public_send(predicate, :none)
        assert_same false, reciever.public_send(predicate, 'none')
        assert_same false, reciever.public_send(predicate, 4)
        assert_same false, reciever.public_send(predicate, 4.9)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
      end
    end
  end

end

class Test_Striuct_Subclass_Predicate_HookTiming_Getter_Disable < Test::Unit::TestCase

  class Subclass < Striuct
    member :no_with
    alias_member :als_no_with, :no_with
    
    member :with, nil, getter_validation: false
    alias_member :als_with, :with
    
    member :with_any, BasicObject, reader_validation: false
    alias_member :als_with_any, :with_any
    
    member :adj_with, nil, reader_validation: false do |_|; end
    alias_member :als_adj_with, :adj_with

    close_member
  end.freeze

  INSTANCE = Subclass.new.freeze
  
  TYPE_PAIRS = {
    class: Subclass,
    instance: INSTANCE
  }.freeze

  [:with_safety_getter?, :with_safety_reader?].each do |predicate|
    TYPE_PAIRS.each_pair do |type, reciever|
      define_method :"test_#{type}_#{predicate}" do
        assert_same false, reciever.public_send(predicate, :no_with)
        assert_same false, reciever.public_send(predicate, :als_no_with)
        assert_same false, reciever.public_send(predicate, 'no_with')
        assert_same false, reciever.public_send(predicate, 'als_no_with')
        assert_same false, reciever.public_send(predicate, 0)
        assert_same false, reciever.public_send(predicate, 0.9)
        
        assert_same false, reciever.public_send(predicate, :with)
        assert_same false, reciever.public_send(predicate, :als_with)
        assert_same false, reciever.public_send(predicate, 'with')
        assert_same false, reciever.public_send(predicate, 'als_with')
        assert_same false, reciever.public_send(predicate, 1)
        assert_same false, reciever.public_send(predicate, 1.9)

        assert_same false, reciever.public_send(predicate, :with_any)
        assert_same false, reciever.public_send(predicate, :als_with_any)
        assert_same false, reciever.public_send(predicate, 'with_any')
        assert_same false, reciever.public_send(predicate, 'als_with_any')
        assert_same false, reciever.public_send(predicate, 2)
        assert_same false, reciever.public_send(predicate, 2.9)

        assert_same false, reciever.public_send(predicate, :adj_with)
        assert_same false, reciever.public_send(predicate, :als_adj_with)
        assert_same false, reciever.public_send(predicate, 'adj_with')
        assert_same false, reciever.public_send(predicate, 'als_adj_with')
        assert_same false, reciever.public_send(predicate, 3)
        assert_same false, reciever.public_send(predicate, 3.9)
        
        assert_same false, reciever.public_send(predicate, :none)
        assert_same false, reciever.public_send(predicate, 'none')
        assert_same false, reciever.public_send(predicate, 4)
        assert_same false, reciever.public_send(predicate, 4.9)
        assert_same false, reciever.public_send(predicate, BasicObject.new)
      end
    end
  end

end