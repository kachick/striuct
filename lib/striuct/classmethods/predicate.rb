class Striuct; module ClassMethods

  # @group Basic Predicate

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
    autonym_for_member name
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

  def has_aliases_for?(autonym)
    @aliases.has_value? autonym.to_sym
  rescue NoMethodError
    false
  end
  
  # @endgroup

end; end
