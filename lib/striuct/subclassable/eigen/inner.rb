class Striuct; module Subclassable; module Eigen
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
  
  def _mark_inference(name)
    @inferences[name] = true
  end
  
  def _set_flavor(name, flavor)
    @flavors[name] = flavor
  end
  
  def _set_conditions(name, conditions)
    @conditions[name] = conditions
  end
  
  def _set_default_value(name, value)
    @defaults[name] = value
  end

  # @param [Symbol, String, #to_sym, #to_str] name
  def originalkey_for(name)
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

  # @param [Symbol, String, #to_sym, #to_str] name
  # @return [Symbol] name(keyable)
  def keyable_for(name)
    return name if name.instance_of? Symbol

    r = (
      case name
      when Symbol, String
        name.to_sym
      else
        case
        when name.respond_to?(:to_sym)
          name.to_sym
        when name.respond_to?(:to_str)
          name.to_str.to_sym
        else
          raise TypeError
        end
      end
    )

    if r.instance_of? Symbol
      r
    else
      raise 'must not happen'
    end
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
    when /\Aeach/, /\A__\w*__\z/, /[!?]\z/, /\Ato_/
      :bad_manners
    when /\A[a-zA-Z_]\w*\z/
      :strict
    else
      raise 'must not happen'
    end
  end

  def initialize_copy(original)
    @names, @flavors, @defaults, @aliases = 
    *[@names, @flavors, @defaults, @aliases].map(&:dup)
    @conditions, @inferences = @conditions.dup, @inferences.dup
  end

  def __getter__!(name) 
    define_method name do
      __get__ name
    end
    
    nil
  end

  def __setter__!(name, *conditions, &flavor)
    __set_conditions__! name, *conditions
    __set_flavor__! name, &flavor if block_given?

    define_method "#{name}=" do |value|
        __set__ name, value
    end
 
    nil

  end
  
  def __set_conditions__!(name, *conditions)
    if conditions.reject!{|c|INFERENCE.equal? c}
      _mark_inference name
    end

    unless conditions.empty?
      if conditions.all?{|c|conditionable? c}
        _set_conditions name, conditions
      else
        raise TypeError, 'wrong object for condition'
      end
    end
 
    nil
  end

  def __set_flavor__!(name, &flavor)
    if (arity = flavor.arity) == 1
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

    raise ArgumentError unless conditionable? family

    _set_conditions name, [family]
    _remove_inference name

    nil
  end
  
  def _conditions_for(name)
    @conditions[name]
  end
  
  # @param [Symbol, String] name
  def conditions_for(name)
    _conditions_for originalkey_for(keyable_for name)
  end
  
  def _flavor_for(name)
    @flavors[name]
  end

  # @param [Symbol, String] name
  def flavor_for(name)
    _flavor_for originalkey_for(keyable_for name)
  end
  
  def _default_for(name)
    @defaults[name]
  end

  # @endgroup
end; end; end