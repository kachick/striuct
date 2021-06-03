# frozen_string_literal: true

require 'keyvalidatable'
require 'optionalargument'

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
      raise TypeError, 'no pairs object' unless pairs.respond_to?(:each_pair)

      KeyValidatable.validate_array(KeyValidatable.keys_for(pairs).map(&:to_sym),
                                    let: all_members)

      instance = allocate
      instance.__send__(:initialize_for_pairs, pairs)
      instance
    end

    alias_method :[], :for_pairs

    # @return [Class]
    DEFINE_OptArg = OptionalArgument.define {
      opt(:lock, default: true, condition: BOOLEAN())
      opt(:strict, default: true, condition: BOOLEAN())
    }

    # for build the fixed object
    # @param [Hash] options
    # @option options [Boolean] :lock
    # @option options [Boolean] :strict
    # @yieldparam [Striuct] instance
    # @yieldreturn [Striuct] instance
    # @return [void]
    def define(options={})
      raise ArgumentError, 'must with block' unless block_given?

      opts = DEFINE_OptArg.parse(options)

      new.tap { |instance|
        yield instance

        yets = autonyms.select { |autonym| !instance.assigned?(autonym) }
        unless yets.empty?
          raise "not assigned members are, yet '#{yets.inspect} in #{self}'"
        end

        invalids = autonyms.select { |autonym| !instance.valid?(autonym) }
        if opts.strict && !invalids.empty?
          raise Validation::InvalidWritingError,
                "invalids members are, yet '#{invalids.inspect} in #{self}'"
        end

        instance.lock_all if opts.lock
      }
    end

    # @endgroup
  end
end
