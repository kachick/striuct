class Striuct; module Subclassable; module Eigen
  # @group Macro for Definition

  private

  # @macro [attach] protect_level
  # @param [Symbol] level
  # @return [nil]
  # change protect level for risk of naming members
  def protect_level(level)
    raise NameError unless PROTECT_LEVELS.has_key? level
    
    @protect_level = level
    nil
  end

  # @macro [attach] member
  # @return [nil]
  def define_member(name, *conditions, &flavor)
    warn 'deprecated multiple conditions here, please use .#OR' if conditions.length >= 2
    raise "already closed to add member in #{self}" if closed?
    name = keyable_for name
    raise ArgumentError, %Q!already exist name "#{name}"! if member? name
    _check_safety_naming name

    @names << name
    __getter__! name
    __setter__! name, *conditions, &flavor
    nil
  end

  alias_method :def_member, :define_member
  alias_method :member, :define_member

  # @macro [attach] define_members
  # @return [nil]
  def define_members(*names)
    raise "already closed to add members in #{self}" if closed?
    unless names.length >= 1
      raise ArgumentError, 'wrong number of arguments (0 for 1+)'
    end
    
    names.each do |name|
      define_member name
    end

    nil
  end

  alias_method :def_members, :define_members

  # @param [Symbol, String] aliased
  # @param [Symbol, String] original
  # @return [nil]
  def alias_member(aliased, original)
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
  
  # @macro [attach] default
  # @return [nil]
  def set_default_value(name, value)
    raise "already closed to modify member attributes in #{self}" if closed?
    name = originalkey_for(keyable_for name)
    raise ConditionError unless accept? name, value

    if has_default? name
      raise "already settled default value for #{name}"
    else
      _set_default_value name, value
      nil
    end
  end
  
  alias_method :default, :set_default_value
  
  # @return [self]
  def close
    [@names, @flavors, @defaults, @aliases].each(&:freeze)
    self
  end
  
  # @endgroup
end; end; end