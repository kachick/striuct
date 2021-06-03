# frozen_string_literal: true

class Striuct
  module InstanceMethods
    # @group Assign / Unassign

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    def assigned?(key)
      @db.key?(autonym_for_key(key))
    end

    alias_method :assign?, :assigned?

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    # @return value / nil - value assigned under the key
    def unassign(key)
      _check_frozen
      _check_locked(key)
      if must?(key)
        raise InvalidOperationError, "`#{key}` require a value under `must` option"
      end

      @db.delete(autonym_for_key(key))
    end

    alias_method :delete_at, :unassign

    # true if all members are not yet assigned
    def empty?
      _autonyms.none? { |autonym| @db.key?(autonym) }
    end

    # @endgroup
  end
end
