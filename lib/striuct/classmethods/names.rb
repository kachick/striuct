# frozen_string_literal: true

class Striuct
  module ClassMethods
    # @group Named

    # @return [Array<Symbol>]
    def autonyms
      @autonyms.dup
    end

    alias_method :members, :autonyms

    # @return [Array<Symbol>]
    def all_members
      @autonyms + @aliases.keys
    end

    # @param [Symbol, String, #to_sym] als
    # @return [Symbol]
    def autonym_for_alias(als)
      @aliases.fetch(als.to_sym)
    rescue NoMethodError
      raise TypeError
    rescue KeyError
      raise NameError
    end

    # @param [Symbol, String, #to_sym] name - autonym / aliased
    # @return [Symbol]
    def autonym_for_member(name)
      raise TypeError unless name.respond_to?(:to_sym)

      name = name.to_sym

      @autonyms.include?(name) ? name : autonym_for_alias(name)
    end

    # @param [Index, #to_int] index
    # @return [Symbol] autonym
    def autonym_for_index(index)
      @autonyms.fetch(index)
    end

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    # @return [Symbol] autonym
    def autonym_for_key(key)
      key.respond_to?(:to_sym) ? autonym_for_member(key) : autonym_for_index(key)
    rescue NameError, IndexError, TypeError
      raise KeyError
    end

    # @param [Symbol, String, #to_sym] autonym
    # @return [Array<Symbol>]
    def aliases_for_autonym(autonym)
      raise TypeError unless autonym.respond_to?(:to_sym)

      autonym = autonym.to_sym
      raise NameError unless with_aliases?(autonym)

      @aliases.select { |_als, aut| autonym == aut }.keys
    end

    # @return [Hash] alias => autonym
    def aliases
      @aliases.dup
    end

    private

    # for direct access inner data from own instance
    # @return [Hash] alias => autonym
    def _autonyms
      @autonyms
    end

    # @endgroup
  end
end
