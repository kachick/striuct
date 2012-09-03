class Striuct; module ClassMethods

  # @group Inner Methods

  private

  def __getter__!(name) 
    define_method name do
      __get__ name
    end
    
    nil
  end

  def _names
    @names
  end
  
  def _alias_member(aliased, original)
    @aliases[aliased] = original
  end
  
  def _autonym_for(aliased)
    @aliases[aliased]
  end
  
  alias_method :_original_for, :_autonym_for

  def _aliases_for(original)
    @aliases.group_by{|aliased, org|org}[original]
  end

  def _remove_inference(name)
    @inferences.delete name
  end
  
  def _mark_setter_validation(name)
    @setter_validations[name] = true
  end

  def _mark_getter_validation(name)
    @getter_validations[name] = true
  end

  def _mark_inference(name)
    @inferences[name] = true
  end
  
  def _set_flavor(name, flavor)
    @flavors[name] = flavor
  end
  
  def _set_condition(name, condition)
    @conditions[name] = condition
  end
  
  def _set_default_value(name, value)
    @defaults[name] = value
  end

  def __setter__!(name, condition, &flavor)
    __set_condition__! name, condition unless Validation::Condition::ANYTHING.equal? condition
    __set_flavor__! name, &flavor if block_given?

    define_method :"#{name}=" do |value|
      __set__ name, value
    end
 
    nil

  end
  
  def __set_condition__!(name, condition)
    if ::Validation.conditionable? condition
      _set_condition name, condition
    else
      raise TypeError, 'wrong object for condition'
    end
 
    nil
  end

  def __set_flavor__!(name, &flavor)
    if ::Validation.adjustable? flavor
      _set_flavor name, flavor
    else
      raise ArgumentError, "wrong number of block argument #{arity} for 1"
    end
 
    nil
  end

  def __found_family__!(_caller, name, our)
    family = our.class

    raise 'must not happen' unless name.instance_of?(Symbol) and
                                   inference?(name) and
                                   member?(name) and
                                   _caller.instance_of?(self)

    raise ArgumentError unless Validation.conditionable? family

    _set_condition name, family
    _remove_inference name

    nil
  end
  
  # @endgroup

end; end