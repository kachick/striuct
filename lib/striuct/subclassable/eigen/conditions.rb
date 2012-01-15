class Striuct; module Subclassable; module Eigen
  private

  # @group Specific Conditions

  # @return [Object] INFERENCE specific key of inference checker
  def inference
    INFERENCE
  end

  # @return [lambda] BOOLEAN check "true or false"
  def boolean
    BOOLEAN
  end
  
  alias_method :bool, :boolean

  # @return [lambda] STRINGABLE check "looks string family"
  def stringable
    STRINGABLE
  end

  # @return [lambda] check "list only included object that match any conditions"
  def generics(condition1, *conditions)
    conditions = [condition1, *conditions]
    unless conditions.all?{|c|conditionable? c}
      raise TypeError, 'wrong object for condition'
    end
    
    eigen = self
    ->list{
      conditions.all?{|condition|
        list.all?{|v|
          eigen.__send__(:pass?, v, condition, self)
        }
      }
    }
  end

  # @return [lambda] check "can repond to all messages"
  def responsible(name1, *names)
    names = [name1, *names]
    unless names.all?{|s|[Symbol, String].any?{|klass|s.kind_of? klass}}
      raise TypeError, 'only Symbol or String for name'
    end
    
    ->v{
      names.all?{|name|v.respond_to?(name)}
    }
  end

  # @return [lambda]
  def unique(list1, *lists)
    lists = [list1, *lists]
    unless lists.all?{|l|l.respond_to? :none?}
      raise TypeError, 'list must respond #none?'
    end
    
    ->v{
      lists.none?{|list|list.include?(v)}
    }
  end

  # @return [lambda] check "match all conditions"
  def AND(first, second, *others)
    conditions = [first, second, *others]
    unless conditions.all?{|c|conditionable? c}
      raise TypeError, 'wrong object for condition'
    end
    
    eigen = self
    ->v{
      conditions.all?{|condition|
        eigen.__send__(:pass?, v, condition, self)
      }
    }
  end

  # @return [lambda] check "match any condition"
  def OR(first, second, *others)
    conditions = [first, second, *others]
    unless conditions.all?{|c|conditionable? c}
      raise TypeError, 'wrong object for condition'
    end
    
    eigen = self
    ->v{
      conditions.any?{|condition|
        eigen.__send__(:pass?, v, condition, self)
      }
    }
  end
  
  # @endgroup
end; end; end