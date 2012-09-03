class Striuct; module ClassMethods

  # @group Named

  # @param [Symbol, String, #to_sym] name
  # @return [Symbol]
  def keyable_for(name)
    name.to_sym
  end

  # @return [Array<Symbol>]
  def names
    @names.dup
  end

  alias_method :autonyms, :names
  alias_method :members, :names
  alias_method :keys, :names
  
  # @return [Array<Symbol>]
  def all_members
    @names + @aliases.keys
  end

  def has_member?(name)
    autonym_for name
  rescue Exception
    false
  else
    true
  end
  
  alias_method :member?, :has_member?
  alias_method :has_key?, :has_member?
  alias_method :key?, :has_key?

  # @param [Symbol, String, #to_sym, #to_str] name
  # @return [Symbol]
  def autonym_for(name)
    name = keyable_for name
    
    if _names.include? name
      name
    else
      if autonym = _autonym_for(name)
        autonym
      else
        raise NameError, "not defined member for #{name}"
      end
    end
  end

  # @param [Symbol, String] name
  def autonym?(name)
    name = keyable_for name
    raise NameError unless member? name

    @names.include? name
  end
  
  alias_method :original?, :autonym?
  
  # @param [Symbol, String] name
  def aliased?(name)
    name = keyable_for name
    raise NameError unless member? name

    @aliases.has_key? name
  end
  
  # @param [Symbol, String] original
  def has_aliases?(autonym)
    raise NameError unless autonym? autonym

    @aliases.has_value? autonym
  end
  
  # @param [Symbol, String] autonym
  # @return [Array<Symbol>]
  def aliases_for(autonym)
    autonym = keyable_for autonym
    raise NameError unless has_aliases? autonym

    _aliases_for autonym
  end
  
  # @return [Hash] alias => autonym
  def aliases
    @aliases.dup
  end

  # @endgroup

end; end