class Striuct; module ClassMethods

  # @group Named

  # @return [Array<Symbol>]
  def autonyms
    @autonyms.dup
  end

  alias_method :members, :autonyms
  
  # @return [Array<Symbol>]
  def all_members
    @autonyms + @aliases.keys
  end

  def has_member?(name)
    autonym_for_name name
  rescue Exception
    false
  else
    true
  end
  
  alias_method :member?, :has_member?

  # @param [Symbol, String, #to_sym] name - autonym / aliased
  # @return [Symbol]
  def autonym_for_name(name)
    name = _nameable_for name
    
    return name if @autonyms.include? name
    
    unless @aliases.has_key? name
      raise NameError, "not defined member for #{name}"
    end
    
    @aliases.fetch name
  end

  alias_method :autonym_for, :autonym_for_name # todo modify to autonym_for_key 

  # @param [Symbol, String, Fixnum] key - autonym / aliased / index
  # @return [Symbol] autonym
  def autonym_for_key(key)
    case key
    when Symbol, String
      name = _nameable_for key
      if member? name
        return autonym_for_name(name)
      else
        raise NameError
      end
    when Fixnum
      if autonym = _autonyms[key]
        return autonym
      else
        raise IndexError
      end
    else
      raise ArgumentError
    end

    raise 'must not happen'
  end

  # @param [Symbol, String] name
  def has_autonym?(name)
    name = _nameable_for name
    raise NameError unless member? name

    @autonyms.include? name
  end
  
  alias_method :autonym?, :has_autonym?
  
  # @param [Symbol, String] name
  def has_alias?(name)
    name = _nameable_for name
    raise NameError unless member? name

    @aliases.has_key? name
  end
  
  alias_method :alias?, :has_alias?
  alias_method :aliased?, :has_alias? # obsolute
  
  # @param [Symbol, String] autonym
  def has_aliases?(autonym)
    raise NameError unless autonym? autonym

    @aliases.has_value? autonym
  end
  
  # @param [Symbol, String] autonym
  # @return [Array<Symbol>]
  def aliases_for(autonym)
    autonym = _nameable_for autonym
    raise NameError unless has_aliases? autonym

    @aliases.group_by{|aliased, an|an}.fetch(autonym)
  end
  
  # @return [Hash] alias => autonym
  def aliases
    @aliases.dup
  end
  
  private

  # @param [Symbol, String, #to_sym] name
  # @return [Symbol]
  def _nameable_for(name)
    name.to_sym
  end
  
  # for access from own instance
  def _autonyms
    @autonyms
  end
  
  # @endgroup

end; end
