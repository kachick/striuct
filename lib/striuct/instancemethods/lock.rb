# frozen_string_literal: true

class Striuct
  module InstanceMethods
    # @group Lock / Unlock

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    # @return [self]
    def lock(key)
      _check_frozen

      @locks[autonym_for_key(key)] = true
      self
    end

    # @return [self]
    def lock_all
      _check_frozen

      each_autonym do |autonym|
        @locks[autonym] = true
      end
    end

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    def locked?(key)
      @locks.key?(autonym_for_key(key))
    end

    def all_locked?
      _autonyms.all? { |autonym| @locks.key?(autonym) }
    end

    private

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    # @return [self]
    def unlock(key)
      _check_frozen

      @locks.delete(autonym_for_key(key))
      self
    end

    # @return [self]
    def unlock_all
      _check_frozen

      @locks.clear
      self
    end

    # @endgroup
  end
end
