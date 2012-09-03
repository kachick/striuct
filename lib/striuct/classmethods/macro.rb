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
  
  def closed?
    [@names, @flavors, @defaults, @aliases].any?(&:frozen?)
  end

  private

  # @param [Symbol, String] name
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
  def add_member(name, condition=Validation::Condition::ANYTHING, options=DEFAULT_MEMBER_OPTIONS, &flavor)
    raise "already closed to add member in #{self}" if closed?
    options = DEFAULT_MEMBER_OPTIONS.merge(options).extend(KeyValidatable)
    options.validate_keys let: VALID_MEMBER_OPTIONS
    if options.has_key?(:default) and options.has_key?(:default_proc)
      raise ArgumentError, 'It is not able to choose "default" with "default_proc" in options'
    end
    
    autonym = keyable_for name # First difinition for an autonym

    raise ArgumentError, %Q!already exist name "#{autonym}"! if member? autonym
    _check_safety_naming autonym
    _mark_setter_validation name if options[:setter_validation] or options[:writer_validation]
    _mark_getter_validation name if options[:getter_validation] or options[:reader_validation]
    _mark_inference name if options[:inference]

    @names << autonym
    __getter__! autonym
    __setter__! autonym, condition, &flavor
    
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
    raise "already closed to add members in #{self}" if closed?
    
    [autonym, *autonyms].each {|_autonym|add_member _autonym}
    nil
  end

  # @param [Symbol, String] aliased
  # @param [Symbol, String] autonym
  # @return [nil]
  def alias_member(aliased, autonym)
    raise "already closed to add members in #{self}" if closed?
    autonym = autonym_for autonym
    aliased  = keyable_for aliased
    raise ArgumentError, %Q!already exist name "#{aliased}"! if member? aliased
    _check_safety_naming aliased

    alias_method aliased, autonym
    alias_method :"#{aliased}=", :"#{autonym}="
    _alias_member aliased, autonym
    nil
  end
  
  # @param [Symbol, String] name
  # @return [nil]
  def set_default_value(name, value=nil, &block)
    raise "already closed to modify member attributes in #{self}" if closed?
    autonym = autonym_for(name)
    raise "already settled default value for #{name}" if has_default? autonym

    value = (
      if block_given?
        if value.nil?
          arity = block.arity
          
          if valid_default_proc? block
            SpecificContainer.new block
          else
            raise ArgumentError, "wrong number of block parameter #{arity} for 0..2"
          end
        else
          raise ArgumentError, 'can not use value and block arguments'
        end
      else
        value
      end
    )
    
    _set_default_value autonym, value
    nil
  end
  
  alias_method :default, :set_default_value
  
  # @param [Proc] _proc
  def valid_default_proc?(_proc)
    _proc.arity <= 2
  end
  
  # @return [self]
  def close_member
    [@names, @flavors, @defaults, @aliases].each(&:freeze)
    self
  end
  
  alias_method :fix_structural, :close_member
  alias_method :close, :close_member
  
  # @endgroup

end; end
