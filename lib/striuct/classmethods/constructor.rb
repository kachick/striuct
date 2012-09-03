require 'keyvalidatable'

class Striuct; module ClassMethods

  # @group Constructor
  
  # @return [Striuct]
  def for_values(*values)
    new_instance(*values)
  end

  alias_method :load_values, :for_values
  alias_method :new, :for_values

  # @param [Hash, Struct] pairs
  # @return [Striuct]
  def for_pairs(pairs)
    unless pairs.respond_to?(:each_pair) and pairs.respond_to?(:keys)
      raise TypeError, 'no pairs object'
    end

    pairs.dup.extend(KeyValidatable).validate_keys let: all_members

    new.tap {|instance|
      pairs.each_pair do |name, value|
        instance[name] = value
      end
    }
  end

  alias_method :load_pairs, :for_pairs
  alias_method :[], :for_pairs

  # for build the fixed object
  # @param [Hash] options
  # @option options [Boolean] :lock
  # @option options [Boolean] :strict
  # @yieldparam [Striuct] instance
  # @yieldreturn [Striuct] instance
  # @return [void]
  def define(options={lock: true, strict: true})
    raise ArgumentError, 'must with block' unless block_given?
    options.dup.extend(KeyValidatable).validate_keys let: [:lock, :strict]
    
    lock, strict = options[:lock], options[:strict]
    
    new.tap {|instance|
      yield instance
  
      unless (yets = autonyms.select{|autonym|! instance.assign?(autonym)}).empty?
        raise "not assigned members are, yet '#{yets.inspect} in #{self}'"
      end
      
      if strict &&
        ! (invalids = autonyms.select{|autonym|! instance.valid?(autonym)}).empty?

        raise Validation::InvalidWritingError, "invalids members are, yet '#{invalids.inspect} in #{self}'"
      end

      instance.lock if lock
    }
  end

  # @endgroup

end; end