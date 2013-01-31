class Striuct; module ClassMethods

  # @group Validation
  
  # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
  def condition_for(key)
    autonym = autonym_for_key key
    raise KeyError unless with_condition? autonym
    
    _attributes_for(autonym).condition
  end

  # @endgroup

end; end