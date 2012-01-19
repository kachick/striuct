class Striuct

  # Useful Condition Patterns
  module Conditions
    module_function  # do not use Module#alias_method

    # @param [Object] condition
    def conditionable?(condition)
      case condition
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
    
    private :_logical_operator

    # @return [lambda] check "match all conditions"
    def AND(cond1, cond2, *conds)
      _logical_operator :all?, cond1, cond2, *conds
    end
  
    # @return [lambda] 
    def NAND(cond1, cond2, *conds)
      ! AND(cond1, cond2, *conds)
    end

    # @return [lambda] check "match any condition"
    def OR(cond1, cond2, *conds)
      _logical_operator :any?, cond1, cond2, *conds
    end

    # @return [lambda] 
    def NOR(cond1, cond2, *conds)
      ! OR(cond1, cond2, *conds)
    end

    # @return [lambda] 
    def XOR(cond1, cond2, *conds)
      _logical_operator :one?, cond1, cond2, *conds
    end

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
    def CAN(name1, *names)
      names = [name1, *names]
      unless names.all?{|s|[Symbol, String].any?{|klass|s.kind_of? klass}}
        raise TypeError, 'only Symbol or String for name'
      end
      
      ->v{
        names.all?{|name|v.respond_to? name}
      }
    end
    
    # @return [lambda] true when faced no exceptions in checking all conditions
    def STILL(condition1, *conditions)
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

    BOOLEAN = OR(SAME(true), SAME(false))

    # @return [BOOLEAN] "true or false"
    def boolean
      BOOLEAN
    end
    
    # @see #boolean
    def bool
      BOOLEAN
    end

    # @return [lambda] check "all included objects match any conditions"
    def GENERICS(condition1, *conditions)
      conditions = [condition1, *conditions]
      unless conditions.all?{|c|conditionable? c}
        raise TypeError, 'wrong object for condition'
      end
      
      ->list{
        conditions.all?{|condition|
          list.all?{|v|
            self.class.__send__(:pass?, v, condition, self)
          }
        }
      }
    end
    
    alias_method :generics, :GENERICS

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

    STRINGABLE = OR(String, Symbol, CAN(:to_str), CAN(:to_sym))

    # @return [STRINGABLE] check "looks string family"
    def stringable
      STRINGABLE
    end
  end

end
