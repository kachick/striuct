class Striuct; module InstanceMethods

  private
  
  # @group Use Only Inner
  
  # see self.class.*args
  delegate_class_methods(
    :keyable_for, :flavor_for, :condition_for, :originalkey_for
  )
  
  def initialize_copy(original)
    @db, @locks = @db.dup, {}
  end

  def __get__(name)
    name = originalkey_for(keyable_for name)
    value = @db[name]
  
    if safety_getter?(name) and !accept?(name, value)
      raise ::Validation::InvalidReadingError,
            "#{value.inspect} is deficient for #{name} in #{self.class}"
    end

    value
  end

  def __set__(name, value)
    raise "can't modify frozen #{self.class}" if frozen?
    name = originalkey_for(keyable_for name)
    raise "can't modify locked member #{name}" if lock? name

    if has_flavor? name
      begin
        value = instance_exec value, &flavor_for(name)
      rescue Exception
        raise ::Validation::UnmanagebleError
      end
    end

    if safety_setter?(name) and !accept?(name, value)
      raise ::Validation::InvalidWritingError,
            "#{value.inspect} is deficient for #{name} in #{self.class}"
    end

    if inference? name
      self.class.__send__ :__found_family__!, self, name, value
    end
    
    @db[name] = value
  rescue ::Validation::InvalidError
    unless /in \[\]=/ =~ caller[1].slice(/([^:]+)\z/)
      $!.backtrace.delete_if{|s|/#{Regexp.escape(File.dirname __FILE__)}/ =~ s}
      $!.backtrace.first.sub!(/([^:]+)\z/){"in `#{name}='"}
    end
  
    raise
  end
  
  def __subscript__(key)
    case key
    when Symbol, String
      name = keyable_for key
      if member? name
        yield originalkey_for(name)
      else
        raise NameError
      end
    when Fixnum
      if name = members[key]
        yield name
      else
        raise IndexError
      end
    else
      raise ArgumentError
    end
  end
  
  # @param [Symbol] name
  def __clear__(name)
    raise "can't modify frozen #{self.class}" if frozen?
    
    @db.delete name
  end

  def replace_values(*values)
    unless values.size <= size
      raise ArgumentError, "struct size differs (max: #{size})"
    end

    values.each_with_index do |value, index|
      self[index] = value
    end
      
    excess = members.last(size - values.size)
      
    excess.each do |name|
      if has_default? name
        self[name] = (
          if (value = default_for name).kind_of? SpecificContainer
            block = value.value
            args = [self, name][0, block.arity]
            block.call(*args)
          else
            value
          end
        )
      end
    end
  end

  # @param [Symbol] method
  def __compare_all__(other, method)
    instance_of?(other.class) && \
    each_pair.all?{|k, v|v.__send__ method, other[k]}
  end
  
  # @endgroup

end; end
