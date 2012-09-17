class Striuct; module ClassMethods

  # @group Adjuster
  
  # @param [Symbol, String] name
  def has_adjuster?(name)
    autonym = autonym_for_member name

    _attributes_for(autonym).has_adjuster?
  end
  
  # @param [Symbol, String] name
  def adjuster_for(name)
    return nil unless has_adjuster? name
    autonym = autonym_for_member name
    
    _attributes_for(autonym).adjuster
  end

  # @endgroup

end; end
