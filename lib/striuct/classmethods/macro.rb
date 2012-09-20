class Striuct; module ClassMethods

  # @group Macro for Member Definition

  ANYTHING = ::Validation::Condition::ANYTHING
  
  ADD_MEMBER_OPTIONS = OptionalArgument.define {
    opt :default_value, aliases: [:default]
    opt :default_proc, aliases: [:lazy_default]
    conflict :default_value, :default_proc
    opt :inference, default: false
    opt :setter_validation, aliases: [:writer_validation], default: true
    opt :getter_validation, aliases: [:reader_validation], default: false
  }

  private

  # @param [Symbol, String, #to_sym] autonym
  # @param [#===, Proc, Method, ANYTHING] condition
  # @param [Hash] options
  # @option options [BasicObject] :default
  # @option options [Proc] :default_proc
  # @option options [Boolean] :inference
  # @option options [Boolean] :reader_validation
  # @option options [Boolean] :getter_validation
  # @option options [Boolean] :writer_validation
  # @option options [Boolean] :setter_validation
  # @return [nil]
  def add_member(autonym, condition=ANYTHING, options={}, &adjuster)
    raise "can't modify frozen Class" if frozen?
    raise "already closed to add member in #{self}" if closed?
    
    options = ADD_MEMBER_OPTIONS.parse options
    autonym = autonym.to_sym # First difinition for an autonym

    raise ArgumentError, %Q!already exist name "#{autonym}"! if member? autonym
    _check_safety_naming autonym
    _add_autonym autonym

    _attributes_for(autonym).safety_setter = !!options.setter_validation
    _attributes_for(autonym).safety_getter = !!options.getter_validation

    if options.inference
      _attributes_for(autonym).inference = true
    end

    _def_getter autonym
    _def_setter autonym, condition, &adjuster
    
    case
    when options.default_value?
      set_default_value autonym, options.default_value
    when options.default_proc?
      set_default_value autonym, &options.default_proc
    end
    
    nil
  end

  alias_method :member, :add_member

  # @param [Symbol, String, #to_sym] autonym
  # @param [Symbol, String, #to_sym] autonyms
  # @return [nil]
  def add_members(autonym, *autonyms)
    raise "can't modify frozen Class" if frozen?
    raise "already closed to add members in #{self}" if closed?
    
    [autonym, *autonyms].each {|_autonym|add_member _autonym}
    nil
  end

  # @param [Symbol, String, #to_sym] aliased
  # @param [Symbol, String, #to_sym] autonym
  # @return [nil]
  def alias_member(aliased, autonym)
    raise "can't modify frozen Class" if frozen?
    raise "already closed to add members in #{self}" if closed?
    autonym = autonym_for_member autonym
    aliased  = aliased.to_sym
    raise ArgumentError, %Q!already exist name "#{aliased}"! if member? aliased
    _check_safety_naming aliased

    alias_method aliased, autonym
    alias_method :"#{aliased}=", :"#{autonym}="
    @aliases[aliased] = autonym
    nil
  end
  
  # @param [Symbol, String, #to_sym] name
  # @return [nil]
  def set_default_value(name, value=nil, &block)
    raise "can't modify frozen Class" if frozen?
    raise "already closed to modify member attributes in #{self}" if closed?
    autonym = autonym_for_member name
    raise "already settled default value for #{name}" if with_default? autonym

    if block_given?
      unless value.nil?
        raise ArgumentError, 'can not use default-value with default-proc'
      end

      _attributes_for(autonym).set_default block, :lazy
    else
      _attributes_for(autonym).set_default value, :value
    end
    
    nil
  end
  
  alias_method :default, :set_default_value

  # @endgroup

end; end
