class Striuct; module ClassMethods

  # @group Inner Methods

  private

  def __getter__!(name) 
    define_method name do
      __get__ name
    end
    
    nil
  end

  def _remove_inference(autonym)
    @inferences.delete autonym
  end
  
  def _mark_setter_validation(autonym)
    @setter_validations[autonym] = true
  end

  def _mark_getter_validation(autonym)
    @getter_validations[autonym] = true
  end

  def _mark_inference(autonym)
    @inferences[autonym] = true
  end
  
  def _set_adjuster(autonym, adjuster)
    @adjusters[autonym] = adjuster
  end
  
  def _set_condition(autonym, condition)
    @conditions[autonym] = condition
  end
  
  def _set_default_value(autonym, value)
    @defaults[autonym] = value
  end

  def __setter__!(autonym, condition, &adjuster)
    __set_condition__! autonym, condition unless Validation::Condition::ANYTHING.equal? condition
    __set_adjuster__! autonym, &adjuster if block_given?

    define_method :"#{autonym}=" do |value|
      __set__ autonym, value
    end
 
    nil

  end
  
  def __set_condition__!(autonym, condition)
    if ::Validation.conditionable? condition
      _set_condition autonym, condition
    else
      raise TypeError, 'wrong object for condition'
    end
 
    nil
  end

  def __set_adjuster__!(autonym, &adjuster)
    if ::Validation.adjustable? adjuster
      _set_adjuster autonym, adjuster
    else
      raise ArgumentError, "wrong number of block argument #{arity} for 1"
    end
 
    nil
  end

  def __found_family__!(_caller, autonym, our)
    family = our.class

    raise 'must not happen' unless inference?(autonym) and
                                    autonym?(autonym) and
                                   _caller.instance_of?(self)

    raise ArgumentError unless Validation.conditionable? family

    _set_condition autonym, family
    _remove_inference autonym

    nil
  end
  
  # @endgroup

end; end