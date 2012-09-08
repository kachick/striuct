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

  def __def_getter__!(autonym) 
    define_method autonym do
      __get__ autonym
    end
    
    nil
  end

  def __def_setter__!(autonym, condition, &adjuster)
    unless Validation::Condition::ANYTHING.equal? condition
      attributes_for(autonym).condition = condition
    end

    if block_given?
      attributes_for(autonym).adjuster = adjuster
    end

    define_method :"#{autonym}=" do |value|
      __set__ autonym, value
    end
 
    nil
  end

  def __found_family__!(_caller, autonym, our)
    family = our.class

    raise 'must not happen' unless inference?(autonym) and
                                    autonym?(autonym) and
                                   _caller.instance_of?(self)

    attributes_for(autonym).condition = family
    attributes_for(autonym).inference = false

    nil
  end
  
  # @endgroup

end; end
