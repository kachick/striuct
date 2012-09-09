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
    setter_validation: true
  }.freeze
  
  private

  # @param [Symbol, String] autonym
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
  def add_member(autonym, condition=Validation::Condition::ANYTHING, options=DEFAULT_MEMBER_OPTIONS, &adjuster)
    raise "can't modify frozen Class" if frozen?
    raise "already closed to add member in #{self}" if closed?
    options = DEFAULT_MEMBER_OPTIONS.merge(options).extend(KeyValidatable)
    options.validate_keys let: VALID_MEMBER_OPTIONS
    if options.has_key?(:default) and options.has_key?(:default_proc)
      raise ArgumentError, 'It is not able to choose "default" with "default_proc" in options'
    end
    
    autonym = nameable_for autonym # First difinition for an autonym

    raise ArgumentError, %Q!already exist name "#{autonym}"! if member? autonym
    _check_safety_naming autonym
    add_autonym autonym

    if options[:setter_validation] or options[:writer_validation]
      attributes_for(autonym).validate_with_setter = true
    end

    if options[:getter_validation] or options[:reader_validation]
      attributes_for(autonym).validate_with_getter = true
    end

    if options[:inference]
      attributes_for(autonym).inference = true
    end

    _def_getter! autonym
    _def_setter! autonym, condition, &adjuster
    
    if options.has_key?(:default)
      set_default_value autonym, options.fetch(:default)
    end
    
    if options.has_key?(:default_proc)
      set_default_value autonym, &options.fetch(:default_proc)
    end
    
    nil
  end

  alias_method :member, :add_member

  # @param [Symbol, String] autonym
  # @param [Symbol, String] autonyms
  # @return [nil]
  def add_members(autonym, *autonyms)
    raise "can't modify frozen Class" if frozen?
    raise "already closed to add members in #{self}" if closed?
    
    [autonym, *autonyms].each {|_autonym|add_member _autonym}
    nil
  end

  # @param [Symbol, String] aliased
  # @param [Symbol, String] autonym
  # @return [nil]
  def alias_member(aliased, autonym)
    raise "can't modify frozen Class" if frozen?
    raise "already closed to add members in #{self}" if closed?
    autonym = autonym_for_name autonym
    aliased  = nameable_for aliased
    raise ArgumentError, %Q!already exist name "#{aliased}"! if member? aliased
    _check_safety_naming aliased

    alias_method aliased, autonym
    alias_method :"#{aliased}=", :"#{autonym}="
    @aliases[aliased] = autonym
    nil
  end
  
  # @param [Symbol, String] name
  # @return [nil]
  def set_default_value(name, value=nil, &block)
    raise "can't modify frozen Class" if frozen?
    raise "already closed to modify member attributes in #{self}" if closed?
    autonym = autonym_for_name(name)
    raise "already settled default value for #{name}" if has_default? autonym

    if block_given?
      unless value.nil?
        raise ArgumentError, 'can not use default-value with default-proc'
      end

      attributes_for(autonym).set_default block, :lazy
    else
      attributes_for(autonym).set_default value, :value
    end
    
    nil
  end
  
  alias_method :default, :set_default_value

  # @endgroup

end; end
