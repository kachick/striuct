class Striuct

  # Useful Condition Patterns
  module Conditions
    ANYTHING = Object.new.freeze
    BOOLEAN = ->v{[true, false].any?{|bool|bool.equal? v}}
  
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

    # @return [lambda] 
    def NOT(condition)
      unless conditionable? condition
        raise TypeError, 'wrong object for condition'
      end
      
      ->v{! pass? v, condition}
    end

    # @return [lambda] 
    def _logical_operator(delegated, *conditions)
      unless conditions.all?{|c|conditionable? c}
        raise TypeError, 'wrong object for condition'
      end
      
      ->v{
        conditions.__send__(delegated) {|condition|
          pass? v, condition
        }
      }
    end

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
            pass? v, condition
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
          pass? v, condition
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
        enum = (
          (list.respond_to?(:each_value) && list.each_value) or
          (list.respond_to?(:all?) && list) or
          (list.respond_to?(:each) && list.each) or
          (raise TypeError, 'not list object')
        )
      
        conditions.all?{|condition|
          enum.all?{|v|
            pass? v, condition
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
