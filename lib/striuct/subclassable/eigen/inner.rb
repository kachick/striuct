class Striuct; module Subclassable; module Eigen
  private

  # @group Use Only Inner

  def pass?(value, condition, context)
    if context && ! context.instance_of?(self)
      raise ArgumentError, "to change context is allowed in instance of #{self}"
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

  # @param [Symbol, String, #to_sym, #to_str] name
  def originalkey_for(name)
    name = keyable_for name
    
    return @aliases[name] if @aliases.has_key? name
    
    if @names.include? name
      name
    else
      raise NameError, "not defined member for #{name}"
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
  def check_safety_naming(name)
    estimation = estimate_naming name
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
  def estimate_naming(name)
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
  
  def __stores__
    [@names, @flavors, @defaults, @aliases]
  end
  
  def initialize_copy(original)
    @names, @flavors, @defaults, @aliases = *__stores__.map(&:dup)
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
      @inferences[name] = true
    end

    unless conditions.empty?
      if conditions.all?{|c|conditionable? c}
        @conditions[name] = conditions
      else
        raise TypeError, 'wrong object for condition'
      end
    end
 
    nil
  end

  def __set_flavor__!(name, &flavor)
    if (arity = flavor.arity) == 1
      @flavors[name] = flavor
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
    
    @conditions[name] = [family]
    @inferences.delete name

    nil
  end

  # @param [Symbol, String] name
  def get_conditions(name)
    name = originalkey_for(keyable_for name)

    @conditions[name]
  end
  
  alias_method :conditions_for, :get_conditions
  
  # @param [Symbol, String] name
  def get_flavor(name)
    name = originalkey_for(keyable_for name)

    @flavors[name]
  end
  
  alias_method :flavor_for, :get_flavor

  # @param [Symbol, String] name
  def get_default_value(name)
    name = originalkey_for(keyable_for name)
  
    @defaults[name]
  end

  # @endgroup
  
  # @group Struct+ Handy

  alias_method :default_for, :get_default_value
  public :default_for
  
  # @endgroup
end; end; end