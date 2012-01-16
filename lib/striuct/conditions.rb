class Striuct; module Subclassable

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
    
    def NOT(condition)
      unless conditionable? condition
        raise TypeError, 'wrong object for condition'
      end
      
      ->v{! self.class.__send__(:pass?, v, condition, self)}
    end
    
    def logical_operator(delegated, *conditions)
      unless conditions.all?{|c|conditionable? c}
        raise TypeError, 'wrong object for condition'
      end
      
      ->v{
        conditions.__send__(delegated) {|condition|
          self.class.__send__(:pass?, v, condition, self)
        }
      }
    end
    
    private :logical_operator

    # @return [lambda] check "match all conditions"
    def AND(cond1, cond2, *conds)
      logical_operator :all?, cond1, cond2, *conds
    end

    def NAND(cond1, cond2, *conds)
      ! AND(cond1, cond2, *conds)
    end

    # @return [lambda] check "match any condition"
    def OR(cond1, cond2, *conds)
      logical_operator :any?, cond1, cond2, *conds
    end
    
    def NOR(cond1, cond2, *conds)
      ! OR(cond1, cond2, *conds)
    end
    
    def XOR(cond1, cond2, *conds)
      logical_operator :one?, cond1, cond2, *conds
    end

    def XNOR(cond1, cond2, *conds)
      ! XOR(cond1, cond2, *conds)
    end

    def EQUAL(obj)
      ->v{obj == v}
    end
    
    def SAME(obj)
      ->v{obj.equal? v}
    end

    # @return [lambda] check "can repond to all messages"
    def responsible_for(name1, *names)
      names = [name1, *names]
      unless names.all?{|s|[Symbol, String].any?{|klass|s.kind_of? klass}}
        raise TypeError, 'only Symbol or String for name'
      end
      
      ->v{
        names.all?{|name|v.respond_to? name}
      }
    end

    # @see #responsible_for
    def CAN(*args)
      responsible_for(*args)
    end
    
    def no_raises_for(condition1, *conditions)
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
    
    # @see #no_raises_for
    def STILL(condition1, *conditions)
      no_raises_for(condition1, *conditions)
    end
    
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

    # @return [BOOLEAN] check "true or false"
    def boolean
      BOOLEAN
    end
    
    # @see #boolean
    def bool
      BOOLEAN
    end

    # @return [lambda] check "all included objects match any conditions"
    def generics(condition1, *conditions)
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

    # @return [lambda]
    def member_of(list1, *lists)
      lists = [list1, *lists]
      unless lists.all?{|l|l.respond_to? :all?}
        raise TypeError, 'list must respond #all?'
      end
      
      ->v{
        lists.all?{|list|list.include? v}
      }
    end

    STRINGABLE = OR(OR(String, Symbol), OR(CAN(:to_str), CAN(:to_sym)))

    # @return [STRINGABLE] check "looks string family"
    def stringable
      STRINGABLE
    end
  end

end; end
