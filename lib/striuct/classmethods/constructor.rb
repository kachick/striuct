# frozen_string_literal: true

class Striuct
  module ClassMethods
    # @group Constructor

    # @return [Striuct]
    def for_values(*values)
      new_instance(*values)
    end

    alias_method :new, :for_values

    # @param [Hash, Struct, Striuct, #each_pair] pairs
    # @return [Striuct]
    def for_pairs(pairs)
      raise ArgumentError, 'no pairs object' unless pairs.respond_to?(:each_pair)
      raise ArgumentError unless pairs.each_pair { |key, _value| all_members.include?(key.to_sym) }

      instance = allocate
      instance.__send__(:initialize_for_pairs, pairs)
      instance
    end

    alias_method :[], :for_pairs

    # for build the fixed object
    # @param [Boolean] lock
    # @param [Boolean] strict
    # @yieldparam [Striuct] instance
    # @yieldreturn [Striuct] instance
    # @return [void]
    def define(lock: true, strict: true)
      raise ArgumentError, 'must with block' unless block_given?

      new.tap { |instance|
        yield instance

        yets = autonyms.select { |autonym| !instance.assigned?(autonym) }
        unless yets.empty?
          raise "not assigned members are, yet '#{yets.inspect} in #{self}'"
        end

        invalids = autonyms.select { |autonym| !instance.valid?(autonym) }
        if strict && !invalids.empty?
          raise Validation::InvalidWritingError,
                "invalids members are, yet '#{invalids.inspect} in #{self}'"
        end

        instance.lock_all if lock
      }
    end

    # @endgroup
  end
end
