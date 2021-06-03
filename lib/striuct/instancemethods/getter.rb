# frozen_string_literal: true

class Striuct
  module InstanceMethods
    # @group Getter

    # @param [Symbol, String, #to_sym] autonym
    def fetch_by_autonym(autonym)
      autonym = autonym.to_sym
      raise NameError unless autonym?(autonym)

      _get(autonym)
    end

    # @param [Symbol, String, #to_sym] member
    def fetch_by_member(member)
      _get(autonym_for_member(member))
    end

    # @param [Integer, #to_int] index
    def fetch_by_index(index)
      _get(autonym_for_index(index))
    end

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    def fetch_by_key(key)
      _get(autonym_for_key(key))
    end

    alias_method :[], :fetch_by_key
    alias_method :fetch, :fetch_by_key

    protected

    # @param [Symbol] autonym - MUST already converted to native autonym
    def _get(autonym)
      value = @db[autonym]

      if with_safety_getter?(autonym) && !accept?(autonym, value)
        raise ::Validation::InvalidReadingError,
              "#{value.inspect} is deficient for #{autonym} in #{self.class}"
      end

      value
    end

    # @endgroup
  end
end
