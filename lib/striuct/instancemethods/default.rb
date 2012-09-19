class Striuct; module InstanceMethods 

  # @group Default Value
 
  # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
  def default?(key)
    autonym = autonym_for_key key

    default_value_for(autonym) == fetch_for_autonym(autonym)
  end

  private

  # @param [Symbol] target_autonyms - MUST already converted to native autonym
  # @return [self]
  def _set_defaults(*target_autonyms)
    target_autonyms.each do |autonym|
      if with_default? autonym
        default = default_value_for autonym
        _set autonym, (
          if default_type_for(autonym) == :lazy
            args = [self, autonym][0, default.arity]
            default.call(*args)
          else
            default
          end
        )
      end
    end
    
    self
  end

  # @endgroup

end; end
