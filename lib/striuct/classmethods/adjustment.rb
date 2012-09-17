class Striuct; module ClassMethods

  # @group Adjuster
  
  # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
  def adjuster_for(key)
    autonym = autonym_for_key key
    raise KeyError unless with_adjuster? autonym
    
    _attributes_for(autonym).adjuster
  end

  # @endgroup

end; end
