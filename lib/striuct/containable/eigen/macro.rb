class Striuct; module Containable; module Eigen
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

  MEMBER_OPTIONS = [:inference].freeze

  # @param [Symbol, String] name
  # @param [#===, Proc, Method, ANYTHING] condition
  # @param [Hash] options
  # @return [nil]
  def add_member(name, condition=ANYTHING, options={}, &flavor)
    raise "already closed to add member in #{self}" if closed?
    raise ArgumentError, 'invalid option parameter is' unless (options.keys - MEMBER_OPTIONS).empty?
    name = keyable_for name
    raise ArgumentError, %Q!already exist name "#{name}"! if member? name
    _check_safety_naming name
    _mark_inference name if options[:inference]

    @names << name
    __getter__! name
    __setter__! name, condition, &flavor
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
    name = originalkey_for(keyable_for name)
    raise "already settled default value for #{name}" if has_default? name

    value = (
      if block_given?
        if value.nil?
          if (arity = block.arity) == 2
            SpecificContainer.new block
          else
            raise ArgumentError, "wrong number of block parameter #{arity} for 2"
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
  
  # @return [self]
  def close_member
    [@names, @flavors, @defaults, @aliases].each(&:freeze)
    self
  end
  
  alias_method :fix_structural, :close_member
  alias_method :close, :close_member
  
  # @endgroup
end; end; end