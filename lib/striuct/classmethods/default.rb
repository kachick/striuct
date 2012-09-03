class Striuct; module ClassMethods

  # @group With default value
  
  # @param [Symbol, String] name
  def has_default?(name)
    autonym = autonym_for name

    @defaults.has_key? autonym
  end
  
  # @param [Symbol, String] name
  def default_for(name)
    autonym = autonym_for name
    raise "#{name} has no default value" unless has_default? autonym
    
    _default_for autonym
  end
  
  private
  
  def _default_for(name)
    @defaults[name]
  end

  # @endgroup

end; end