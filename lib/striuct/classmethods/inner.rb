class Striuct; module ClassMethods

  # @group Inner Methods

  private

  def add_autonym(autonym)
    autonym = keyable_for autonym
    raise NameError, 'already defined' if member? autonym

    @attributes[autonym] = Attributes.new
    @autonyms << autonym
  end

  def attributes_for(autonym)
    @attributes.fetch autonym
  end

  def __getter__!(name) 
    define_method name do
      __get__ name
    end
    
    nil
  end

  def __setter__!(autonym, condition, &adjuster)
    unless Validation::Condition::ANYTHING.equal? condition
      __set_condition__! autonym, condition 
    end

    if block_given?
      __set_adjuster__! autonym, &adjuster
    end

    define_method :"#{autonym}=" do |value|
      __set__ autonym, value
    end
 
    nil
  end
  
  def __set_condition__!(autonym, condition)
    unless ::Validation.conditionable? condition
      raise TypeError, 'wrong object for condition' 
    end

    attributes_for(autonym).condition = condition 
    nil
  end

  def __set_adjuster__!(autonym, &adjuster)
    unless ::Validation.adjustable? adjuster
      raise ArgumentError, "wrong number of block argument #{arity} for 1"
    end
    
    attributes_for(autonym).adjuster = adjuster 
    nil
  end

  def __found_family__!(_caller, autonym, our)
    family = our.class

    raise 'must not happen' unless inference?(autonym) and
                                    autonym?(autonym) and
                                   _caller.instance_of?(self)

    __set_condition__! autonym ,family
    attributes_for(autonym).inference = false

    nil
  end
  
  # @endgroup

end; end
