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

  def has_autonym?(name)
    @autonyms.include? name.to_sym
  rescue NoMethodError
    false
  end
  
  alias_method :autonym?, :has_autonym?
 
  def has_alias?(name)
    @aliases.has_key? name.to_sym
  rescue NoMethodError
    false
  end
  
  alias_method :alias?, :has_alias?
  alias_method :aliased?, :has_alias? # obsolute

  def has_member?(name)
    autonym_for_name name
  rescue Exception
    false
  else
    true
  end
  
  alias_method :member?, :has_member?

  def has_index?(index)
    @autonyms.fetch index
  rescue Exception
    false
  else
    true
  end

  alias_method :index?, :has_index?

  def has_key?(key)
    has_member?(key) || has_index?(key)
  end

  alias_method :key?, :has_key?

  # @param [Symbol, String, #to_sym] als
  # @return [Symbol]
  def autonym_for_alias(als) 
    @aliases.fetch als.to_sym
  end

  # @param [Symbol, String, #to_sym] name - autonym / aliased
  # @return [Symbol]
  def autonym_for_name(name)
    name = name.to_sym
    
    return name if @autonyms.include? name
    
    if @aliases.has_key? name
       autonym_for_alias name
    else
      raise NameError, "not defined member for #{name}"
    end
  end

  alias_method :autonym_for, :autonym_for_name # todo modify to autonym_for_key 

  # @param [Index, #to_int] index
  # @return [Symbol] autonym
  def autonym_for_index(index)
    @autonyms.fetch index
  end

  # @param [Symbol, String, #to_sym, Integer, #to_int] key
  #   autonym / aliased / index
  # @return [Symbol] autonym
  def autonym_for_key(key)
    key.respond_to?(:to_sym) ? autonym_for_name(key) : autonym_for_index(key)
  end
  
  def has_aliases_for?(autonym)
    @aliases.has_value? autonym.to_sym
  rescue NoMethodError
    false
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
