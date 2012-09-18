require 'keyvalidatable'

class Striuct; module ClassMethods

  # @group Macro for Member Definition

  VALID_MEMBER_OPTIONS = [
    :default,
    :default_proc,
    :inference,
    :reader_validation,
    :getter_validation,
    :writer_validation,
    :setter_validation
  ].freeze
  
  DEFAULT_MEMBER_OPTIONS = {
    inference:         false,
    setter_validation: true
  }.freeze

  ANYTHING = ::Validation::Condition::ANYTHING
  
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
    
    opts_base = DEFAULT_MEMBER_OPTIONS.dup
  
    if options.has_key?(:setter_validation) and options.has_key?(:writer_validation)
      raise ArgumentError, 'conflict option parameters'
    end
    
    if options.has_key?(:getter_validation) and options.has_key?(:reader_validation)
      raise ArgumentError, 'conflict option parameters'
    end
    
    if options.has_key?(:writer_validation)
      opts_base.delete :setter_validation
    end
    
    if options.has_key?(:reader_validation)
      opts_base.delete :getter_validation
    end
    
    options = opts_base.merge(options).extend(KeyValidatable)
    options.validate_keys let: VALID_MEMBER_OPTIONS
    if options.has_key?(:default) and options.has_key?(:default_proc)
      raise ArgumentError,
        'It is not able to choose "default" with "default_proc" in same options'
    end
    
    autonym = autonym.to_sym # First difinition for an autonym

    raise ArgumentError, %Q!already exist name "#{autonym}"! if member? autonym
    _check_safety_naming autonym
    _add_autonym autonym

    _attributes_for(autonym).safety_setter = 
      !!(options[:setter_validation] || options[:writer_validation])
    
    _attributes_for(autonym).safety_getter = 
      !!(options[:getter_validation] || options[:reader_validation])

    if options[:inference]
      _attributes_for(autonym).inference = true
    end

    _def_getter autonym
    _def_setter autonym, condition, &adjuster
    
    if options.has_key?(:default)
      set_default_value autonym, options.fetch(:default)
    end
    
    if options.has_key?(:default_proc)
      set_default_value autonym, &options.fetch(:default_proc)
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
