class Striuct; module InstanceMethods 

  # @group Default Value
 
  # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
  def default?(key)
    autonym = autonym_for_key key

    default_value_for(autonym) == fetch_for_autonym(autonym)
  end

  # @endgroup

end; end
