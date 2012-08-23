class Striuct; module ClassMethods
  # @group Use Only Inner

  private

  def _names
    @names
  end
  
  def _alias_member(aliased, original)
    @aliases[aliased] = original
  end
  
  def _original_for(aliased)
    @aliases[aliased]
  end

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

  # @param [Symbol, String, #to_sym, #to_str] name
  def autonym_for(name)
    name = keyable_for name
    
    if _names.include? name
      name
    else
      if original = _original_for(name)
        original
      else
        raise NameError, "not defined member for #{name}"
      end
    end
  end

  # @param [Symbol, String, #to_sym] name
  # @return [Symbol]
  def keyable_for(name)
    name.to_sym
  end

  # @param [Symbol] name
  # @return [void]
  # @yieldreturn [Boolean]
  def _check_safety_naming(name)
    estimation = _estimate_naming name
    risk    = NAMING_RISKS[estimation]
    plevels = PROTECT_LEVELS[@protect_level]
    caution = "undesirable naming '#{name}', because #{estimation}"

    r = (
      case
      when risk >= plevels[:error]
        raise NameError, caution unless block_given?
        false
      when risk >= plevels[:warn]
        warn caution unless block_given?
        false
      else
        true
      end
    )

    yield r if block_given?
  end
  
  # @param [Symbol] name
  # @return [Symbol]
  def _estimate_naming(name)
    if (instance_methods + private_instance_methods).include? name
      return :conflict
    end

    return :no_ascii unless name.encoding.equal? Encoding::ASCII

    case name
    when /[\W]/, /\A[^a-zA-Z_]/, :''
      :no_identifier
    when /\Aeach/, /\A__[^_]*__\z/, /\A_[^_]*\z/, /[!?]\z/, /\Ato_/
      :bad_manners
    when /\A[a-zA-Z_]\w*\z/
      :strict
    else
      raise 'must not happen'
    end
  end

  def __getter__!(name) 
    define_method name do
      __get__ name
    end
    
    nil
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
  
  def _condition_for(name)
    @conditions[name]
  end
  
  # @param [Symbol, String] name
  def condition_for(name)
    _condition_for autonym_for(keyable_for name)
  end
  
  def _flavor_for(name)
    @flavors[name]
  end

  # @param [Symbol, String] name
  def flavor_for(name)
    _flavor_for autonym_for(keyable_for name)
  end
  
  def _default_for(name)
    @defaults[name]
  end

  # @endgroup
end; end