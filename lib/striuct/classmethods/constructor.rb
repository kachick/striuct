class Striuct; module ClassMethods
  # @group Constructor
  
  # @return [Subclass]
  def for_values(*values)
    new_instance(*values)
  end

  alias_method :load_values, :for_values
  alias_method :new, :for_values

  # @param [Hash, Struct]
  # @return [Striuct]
  def for_pairs(pairs)
    unless pairs.respond_to?(:each_pair) and pairs.respond_to?(:keys)
      raise TypeError, 'no pairs object'
    end

    raise ArgumentError, "different members" unless (pairs.keys - keys).empty?

    new.tap {|instance|
      pairs.each_pair do |name, value|
        instance[name] = value
      end
    }
  end

  alias_method :load_pairs, :for_pairs
  alias_method :[], :for_pairs

  # @yieldparam [Striuct] instance
  # @yieldreturn [Striuct] instance
  # @return [void]
  # for build the fixed object
  def define(options={lock: true, strict: true})
    raise TypeError, 'arguments have to be pairs object' unless options.respond_to? :keys
    raise ArgumentError, 'Unknown parameters' unless (options.keys - [:lock, :strict]).empty?
    raise ArgumentError, 'must with block' unless block_given?
    
    lock, strict = options[:lock], options[:strict]
    
    new.tap {|instance|
      yield instance
  
      unless (yets = each_name.select{|name|! instance.assign?(name)}).empty?
        raise "not assigned members are, yet '#{yets.inspect} in #{self}'"
      end
      
      if strict &&
        ! (invalids = each_name.select{|name|! instance.valid?(name)}).empty?

        raise Validation::InvalidWritingError, "invalids members are, yet '#{invalids.inspect} in #{self}'"
      end

      instance.lock if lock
    }
  end

  # @endgroup
end; end