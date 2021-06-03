# frozen_string_literal: true

class Striuct
  module ClassMethods
    # @group With default value

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    def default_value_for(key)
      autonym = autonym_for_key(key)
      raise KeyError unless with_default?(autonym)

      _attributes_for(autonym).default_value
    end

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    # @return [Symbol] :value / :proc
    def default_type_for(key)
      autonym = autonym_for_key(key)
      raise KeyError unless with_default?(autonym)

      _attributes_for(autonym).default_type
    end

    # @endgroup
  end
end
