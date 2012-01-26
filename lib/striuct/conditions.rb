class Striuct

  # Useful Condition Patterns
  module Conditions
    ANYTHING = Object.new.freeze
  
    module_function
    
    def anything
      ANYTHING
    end

    # @param [Object] condition
    def conditionable?(condition)
      case condition
      when ANYTHING
        true
      when Proc, Method
        condition.arity == 1
      else
        condition.respond_to? :===
      end
    end

    # @param [Object] value
    # @param [Proc, Method, #===] condition
    # @param [self(class)] context
    def pass?(value, condition, context)
      if context && ! context.instance_of?(self)
        raise ArgumentError,
              "to change context is allowed in instance of #{self}"
      end

      case condition
      when ANYTHING
        true
      when Proc
        if context
          context.instance_exec value, &condition
        else
          condition.call value
        end
      when Method
        condition.call value
      else
        condition === value
      end ? true : false
    end

    # @return [lambda] 
    def NOT(condition)
      unless conditionable? condition
        raise TypeError, 'wrong object for condition'
      end
      
      ->v{! self.class.__send__(:pass?, v, condition, self)}
    end

    # @return [lambda] 
    def _logical_operator(delegated, *conditions)
      unless conditions.all?{|c|conditionable? c}
        raise TypeError, 'wrong object for condition'
      end
      
      ->v{
        conditions.__send__(delegated) {|condition|
          self.class.__send__(:pass?, v, condition, self)
        }
      }
    end

    # @return [lambda] check "match all conditions"
    def AND(cond1, cond2, *conds)
      _logical_operator :all?, cond1, cond2, *conds
    end
    
    alias_method :ALL, :AND
    module_function :ALL
  
    # @return [lambda] 
    def NAND(cond1, cond2, *conds)
      ! AND(cond1, cond2, *conds)
    end

    # @return [lambda] check "match any condition"
    def OR(cond1, cond2, *conds)
      _logical_operator :any?, cond1, cond2, *conds
    end

    alias_method :ANY, :OR
    module_function :ANY

    # @return [lambda] 
    def NOR(cond1, cond2, *conds)
      ! OR(cond1, cond2, *conds)
    end

    # @return [lambda] 
    def XOR(cond1, cond2, *conds)
      _logical_operator :one?, cond1, cond2, *conds
    end
    
    alias_method :ONE, :XOR
    module_function :ONE

    # @return [lambda] 
    def XNOR(cond1, cond2, *conds)
      ! XOR(cond1, cond2, *conds)
    end

    # @return [lambda] use #==
    def EQUAL(obj)
      ->v{obj == v}
    end
    
    # @return [lambda] use #equal?
    def SAME(obj)
      ->v{obj.equal? v}
    end

    # @return [lambda] true when respond to all method names
    def RESPONSIBLE(name1, *names)
      names = [name1, *names]
      unless names.all?{|s|[Symbol, String].any?{|klass|s.kind_of? klass}}
        raise TypeError, 'only Symbol or String for name'
      end
      
      ->v{
        names.all?{|name|v.respond_to? name}
      }
    end

    alias_method :CAN, :RESPONSIBLE
    alias_method :RESPOND_TO, :RESPONSIBLE
    alias_method :responsible, :RESPONSIBLE
    module_function :CAN, :responsible, :RESPOND_TO
    
    # @return [lambda] true when faced no exceptions in checking all conditions
    def NO_RAISES(condition1, *conditions)
      conditions = [condition1, *conditions]
      unless conditions.all?{|c|conditionable? c}
        raise TypeError, 'wrong object for condition'
      end
      
      ->v{
        conditions.all?{|condition|
          begin
            self.class.__send__(:pass?, v, condition, self)
          rescue Exception
            false
          else
            true
          end
        }
      }
    end
    
    alias_method :STILL, :NO_RAISES
    module_function :STILL
    
    # @return [lambda] true when catch the exception
    def CATCH(exception=Exception, &condition)
      raise ArgumentError unless conditionable? condition
      raise TypeError unless exception.ancestors.include? Exception
      
      ->v{
        begin
          self.class.__send__(:pass?, v, condition, self)
        rescue exception
          true
        rescue Exception
          false
        else
          false
        end
      }
    end
    
    alias_method :RESCUE, :CATCH
    module_function :RESCUE

    # @return [lambda] check "all included objects match any conditions"
    def GENERICS(condition1, *conditions)
      conditions = [condition1, *conditions]
      unless conditions.all?{|c|conditionable? c}
        raise TypeError, 'wrong object for condition'
      end
      
      ->list{
        conditions.all?{|condition|
          (list.respond_to?(:each_value) ? list.each_value : list.each).all?{|v|
            self.class.__send__(:pass?, v, condition, self)
          }
        }
      }
    end
    
    alias_method :generics, :GENERICS
    module_function :generics

    # @return [lambda]
    def MEMBER_OF(list1, *lists)
      lists = [list1, *lists]
      unless lists.all?{|l|l.respond_to? :all?}
        raise TypeError, 'list must respond #all?'
      end
      
      ->v{
        lists.all?{|list|list.include? v}
      }
    end
    
    alias_method :member_of, :MEMBER_OF
    module_function :member_of
    
    BOOLEAN = OR(SAME(true), SAME(false))

    # @return [BOOLEAN] "true or false"
    def boolean
      BOOLEAN
    end

    alias_method :bool, :boolean
    module_function :bool

    STRINGABLE = OR(String, Symbol, CAN(:to_str), CAN(:to_sym))

    # @return [STRINGABLE] check "looks string family"
    def stringable
      STRINGABLE
    end
    
    class << self
      private :_logical_operator
    end
  end

end
