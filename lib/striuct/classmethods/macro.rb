require 'keyvalidatable'

class Striuct; module ClassMethods
  # @group Macro for Definition

  private

  # @param [Symbol] level
  # @return [nil]
  # change protect level for risk of naming members
  def protect_level(level)
    raise NameError unless PROTECT_LEVELS.has_key? level
    
    @protect_level = level
    nil
  end

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
    
    name = keyable_for name
    raise ArgumentError, %Q!already exist name "#{name}"! if member? name
    _check_safety_naming name
    _mark_setter_validation name if options[:setter_validation] or options[:writer_validation]
    _mark_getter_validation name if options[:getter_validation] or options[:reader_validation]
    _mark_inference name if options[:inference]

    @names << name
    __getter__! name
    __setter__! name, condition, &flavor
    
    if options.has_key?(:default)
      set_default_value name, options.fetch(:default)
    end
    
    if options.has_key?(:default_proc)
      set_default_value name, &options.fetch(:default_proc)
    end
    
    nil
  end

  alias_method :member, :add_member

  # @param [Symbol, String] name
  # @param [Symbol, String] *names
  # @return [nil]
  def add_members(name, *names)
    raise "already closed to add members in #{self}" if closed?
    
    [name, *names].each {|_name|add_member _name}
    nil
  end

  # @param [Symbol, String] aliased
  # @param [Symbol, String] original
  # @return [nil]
  def alias_member(aliased, original)
    raise "already closed to add members in #{self}" if closed?
    original = keyable_for original
    aliased  = keyable_for aliased
    raise NameError unless member? original
    raise ArgumentError, %Q!already exist name "#{aliased}"! if member? aliased
    _check_safety_naming aliased

    alias_method aliased, original
    alias_method "#{aliased}=", "#{original}="
    _alias_member aliased, original
    nil
  end
  
  # @param [Symbol, String] name
  # @return [nil]
  def set_default_value(name, value=nil, &block)
    raise "already closed to modify member attributes in #{self}" if closed?
    name = autonym_for(name)
    raise "already settled default value for #{name}" if has_default? name

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
    
    _set_default_value name, value
    nil
  end
  
  alias_method :default, :set_default_value
  
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
