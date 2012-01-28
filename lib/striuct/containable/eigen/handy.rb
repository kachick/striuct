class Striuct; module Containable; module Eigen
  # @group Struct+ Handy

  # @yield [name] 
  # @yieldparam [Symbol] name - sequential under defined
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_name(&block)
    return to_enum(__method__) unless block_given?
    _names.each(&block)
    self
  end

  alias_method :each_member, :each_name
  alias_method :each_key, :each_name
  
  # @yield [index] 
  # @yieldparam [Integer] Index
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_index(&block)
    return to_enum(__method__) unless block_given?
    _names.each_index(&block)
    self
  end
  
  # @param [Symbol, String] name
  def original?(name)
    if member? name
      @names.include? name
    else
      raise NameError
    end
  end
  
  # @param [Symbol, String] name
  def aliased?(name)
    if member? name
      @aliases.has_key? name
    else
      raise NameError
    end
  end
  
  # @param [Symbol, String] original
  def has_aliases?(original)
    if original? original
      @aliases.has_value? original
    else
      raise NameError
    end
  end
  
  # @param [Symbol, String] original
  # @return [Array<Symbol>]
  def aliases_for(original)
    original = keyable_for original

    if has_aliases? original
      _aliases_for original
    else
      raise NameError
    end
  end

  # @param [Symbol, String] name
  def has_flavor?(name)
    name = originalkey_for(keyable_for name)

    ! flavor_for(name).nil?
  end

  # @param [Symbol, String] name
  def has_default?(name)
    name = originalkey_for(keyable_for name)

    @defaults.has_key? name
  end
  
  # @param [Symbol, String] name
  def default_for(name)
    name = originalkey_for(keyable_for name)
  
    if has_default? name
      _default_for name
    else
      raise "#{name} has no default value"
    end
  end

  # @endgroup
end; end; end