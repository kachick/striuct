class Striuct

  # Condition Builders and Useful Conditions
  #
  # Any conditions need #pass?(arg, condition) method
  # @author Kenichi Kamiya
  # @example overview
  #   class Person < Striuct
  #     member :name, OR(String, Symbol, CAN(:to_str))
  #     member :friends, GENERICS(AND(Person, NOT(->v{equal? v})))
  module Conditions
    ANYTHING = Object.new.freeze
    BOOLEAN = ->v{[true, false].any?{|bool|bool.equal? v}}
  
    module_function
    
    # The getter for a special condition.
    # @return [ANYTHING] A condition always pass with any objects.
    def ANYTHING?
      ANYTHING
    end

    alias_method :ANYTHING, :ANYTHING?  
    alias_method :anything, :ANYTHING?
    module_function :anything, :ANYTHING

    # true if object is sufficient for condition.
    # @param [Object] object
    def conditionable?(object)
      case object
      when ANYTHING
        true
      when Proc, Method
        object.arity == 1
      else
        object.respond_to? :===
      end
    end
    
    # A condition builder.
    # @return [lambda] A condition invert the original condition.
    def NOT(condition)
      unless conditionable? condition
        raise TypeError, 'wrong object for condition'
      end
      
      ->v{! pass?(v, condition)}
    end

    # A innner method for some condition builders.
    # For build conditions AND, NAND, OR, NOR, XOR, XNOR.
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

    # A condition builder.
    # @return [lambda]
    #   this lambda return true if match all conditions
    def AND(cond1, cond2, *conds)
      _logical_operator :all?, cond1, cond2, *conds
    end
  
    # A condition builder.
    # @return [lambda] 
    def NAND(cond1, cond2, *conds)
      NOT AND(cond1, cond2, *conds)
    end

    # A condition builder.
    # @return [lambda]
    #   this lambda return true if match a any condition
    def OR(cond1, cond2, *conds)
      _logical_operator :any?, cond1, cond2, *conds
    end

    # A condition builder.
    # @return [lambda] 
    def NOR(cond1, cond2, *conds)
      NOT OR(cond1, cond2, *conds)
    end

    # A condition builder.
    # @return [lambda] 
    def XOR(cond1, cond2, *conds)
      _logical_operator :one?, cond1, cond2, *conds
    end
    
    alias_method :ONE, :XOR
    module_function :ONE

    # A condition builder.
    # @return [lambda] 
    def XNOR(cond1, cond2, *conds)
      NOT XOR(cond1, cond2, *conds)
    end

    # A condition builder.
    # @return [lambda]
    #   this lambda return true if a argment match under #== method
    def EQUAL(obj)
      ->v{obj == v}
    end

    # A condition builder.
    # @return [lambda]
    #   this lambda return true if a argment match under #equal? method
    def SAME(obj)
      ->v{obj.equal? v}
    end

    # A condition builder.
    # @param [Symbol, String] messages
    # @return [lambda]
    #   this lambda return true if a argment respond to all messages
    def RESPONSIBLE(message1, *messages)
      messages = [message1, *messages]
      unless messages.all?{|s|
                [Symbol, String].any?{|klass|s.kind_of? klass}
              }
        raise TypeError, 'only Symbol or String for message'
      end
      
      ->v{
        messages.all?{|message|v.respond_to? message}
      }
    end

    alias_method :CAN, :RESPONSIBLE
    alias_method :RESPOND_TO, :RESPONSIBLE
    alias_method :responsible, :RESPONSIBLE
    module_function :CAN, :responsible, :RESPOND_TO

    # A condition builder.
    # @return [lambda]
    #   this lambda return true
    #   if face no exception when a argment checking under all conditions 
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
  
    # A condition builder.
    # @return [lambda]
    #   this lambda return true
    #   if catch a kindly exception when a argment checking in a block parameter
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

    # A condition builder.
    # @return [lambda]
    #   this lambda return true
    #   if all included objects match all conditions
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
          return false
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
  
    # A condition builder.
    # @return [lambda]
    #   this lambda return true
    #   if all lists including the object
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

    # A getter for a useful condition.
    # @return [BOOLEAN] "true or false"
    def BOOLEAN?
      BOOLEAN
    end

    alias_method :boolean, :BOOLEAN?
    alias_method :bool, :BOOLEAN?
    alias_method :BOOLEAN, :BOOLEAN?
    alias_method :BOOL, :BOOLEAN?
    alias_method :BOOL?, :BOOLEAN?
    module_function :boolean, :bool, :BOOLEAN, :BOOL, :BOOL?

    STRINGABLE = OR(String, Symbol, CAN(:to_str), CAN(:to_sym))

    # A getter for a useful condition.
    # @return [STRINGABLE] check "looks string family"
    def STRINGABLE?
      STRINGABLE
    end
    
    alias_method :stringable, :STRINGABLE?
    alias_method :STRINGABLE, :STRINGABLE?
    module_function :stringable, :STRINGABLE
    
    class << self
      private :_logical_operator
    end
  end

end
