class Striuct; module ClassMethods
  # @group Struct+ Handy

  # @yield [name] 
  # @yieldparam [Symbol] name - sequential under defined
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_name
    return to_enum(__method__) unless block_given?
    _names.each{|name|yield name}
    self
  end

  alias_method :each_member, :each_name
  alias_method :each_key, :each_name
  
  # @yield [index] 
  # @yieldparam [Integer] Index
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_index
    return to_enum(__method__) unless block_given?
    _names.each_index{|index|yield index}
    self
  end

  # @yield [name, index]
  # @yieldparam [Symbol] name
  # @yieldparam [Integer] index
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_name_with_index
    return to_enum(__method__) unless block_given?
    _names.each_with_index{|name, index|yield name, index}
    self
  end
  
  alias_method :each_member_with_index, :each_name_with_index
  alias_method :each_key_with_index, :each_name_with_index

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
  
  # @return [Hash] alias => autonym
  def aliases
    @aliases.dup
  end

  # @param [Symbol, String] name
  def has_flavor?(name)
    name = autonym_for name

    ! flavor_for(name).nil?
  end

  # @param [Symbol, String] name
  def has_default?(name)
    name = autonym_for name

    @defaults.has_key? name
  end
  
  # @param [Symbol, String] name
  def default_for(name)
    name = autonym_for name
  
    if has_default? name
      _default_for name
    else
      raise "#{name} has no default value"
    end
  end
  
  # @return [Class]
  def to_struct_class
    raise 'No defined members' if names.empty?

    struct_klass = Struct.new(*names)
  
    if name
      tail_name = name.slice(/[^:]+\z/)
      if ::Striuct::Structs.const_defined?(tail_name) && 
          ((already = ::Striuct::Structs.const_get(tail_name)).members == members)
          already
      else
        ::Striuct::Structs.const_set tail_name, struct_klass
      end
    else
      struct_klass
    end
  end

  # @endgroup
end; end