class Striuct; module ClassMethods

  # @group With default value
  
  # @param [Symbol, String] name
  def has_default?(name)
    autonym = autonym_for name

    attributes_for(autonym).has_default?
  end
  
  # @param [Symbol, String] name
  def default_value_for(name)
    autonym = autonym_for name
    raise "#{name} has no default value" unless has_default? autonym
 
    attributes_for(autonym).default_value
  end

  alias_method :default_for, :default_value_for

  # @param [Symbol, String] name
  # @return [Symbol] :value / :proc
  def default_type_for(name)
    autonym = autonym_for name
    raise "#{name} has no default value" unless has_default? autonym
 
    attributes_for(autonym).default_type
  end
  
  # @endgroup

end; end
