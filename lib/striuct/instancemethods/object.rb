# frozen_string_literal: true

class Striuct
  module InstanceMethods
    # @group Basic Methods for Ruby's Object

    # @return [self]
    def freeze
      @db.freeze; @locks.freeze
      super
    end

    private

    def initialize(*values)
      _initialize_database

      replace_values(*values)
      excess_autonyms = _autonyms.last(size - values.size)
      _set_defaults(*excess_autonyms)

      each_autonym do |autonym|
        _check_must(autonym)
      end
    end

    def initialize_for_pairs(pairs)
      _initialize_database

      excess_autonyms = _autonyms.dup
      pairs.each_pair do |key, value|
        autonym = autonym_for_key(key)
        self[autonym] = value
        excess_autonyms.delete(autonym)
      end

      _set_defaults(*excess_autonyms)

      excess_autonyms.each do |autonym|
        _check_must(autonym)
      end
    end

    def initialize_copy(original)
      @db, @locks = @db.dup, {}
    end

    def _initialize_database
      @db, @locks = {}, {}
    end

    def _check_frozen
      raise "can't modify frozen #{self.class}" if frozen?
    end

    def _check_locked(key)
      raise "can't modify locked member `#{key}`" if locked?(key)
    end

    def _check_must(key)
      if must?(key) && !assigned?(key)
        raise InvalidOperationError, "`#{key}` require a value under `must` option"
      end
    end

    # @endgroup
  end; end
