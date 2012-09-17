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
 
  # @param [Symbol, String, #to_sym] als
  # @return [Symbol]
  def autonym_for_alias(als) 
    @aliases.fetch als.to_sym
  end

  # @param [Symbol, String, #to_sym] name - autonym / aliased
  # @return [Symbol]
  def autonym_for_member(name)
    name = name.to_sym
    
    return name if @autonyms.include? name
    
    if @aliases.has_key? name
       autonym_for_alias name
    else
      raise NameError, "not defined member for #{name}"
    end
  end

  # @param [Index, #to_int] index
  # @return [Symbol] autonym
  def autonym_for_index(index)
    @autonyms.fetch index
  end

  # @param [Symbol, String, #to_sym, Integer, #to_int] key
  #   autonym / aliased / index
  # @return [Symbol] autonym
  def autonym_for_key(key)
    key.respond_to?(:to_sym) ? autonym_for_member(key) : autonym_for_index(key)
  end

  # @param [Symbol, String] autonym
  # @return [Array<Symbol>]
  def aliases_for(autonym)
    autonym = autonym.to_sym
    raise NameError unless has_aliases? autonym

    @aliases.group_by{|aliased, an|an}.fetch(autonym)
  end
  
  # @return [Hash] alias => autonym
  def aliases
    @aliases.dup
  end
  
  private

  # for access from own instance
  def _autonyms
    @autonyms
  end
  
  # @endgroup

end; end
