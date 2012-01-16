class Striuct; module Subclassable
  private
  
  # @group Use Only Inner
  
  # see self.class.*args
  delegate_class_methods(
    :keyable_for, :flavor_for, :conditions_for, :originalkey_for
  )
  
  def initialize_copy(original)
    @db, @locks = @db.dup, {}
  end

  def __get__(name)
    name = originalkey_for(keyable_for name)

    @db[name]
  end

  def __set__(name, value)
    raise "can't modify frozen #{self.class}" if frozen?
    name = originalkey_for(keyable_for name)
    raise "can't modify locked member #{name}" if lock? name

    unless accept? name, value
      raise ConditionError,
            "#{value.inspect} is deficient for #{conditions_for(name).inspect}"
    end
          
    if has_flavor? name
      value = instance_exec value, &flavor_for(name)
    end

    if inference? name
      self.class.__send__ :__found_family__!, self, name, value
    end
    
    @db[name] = value
  rescue ConditionError
    unless /in \[\]=/ =~ caller[1].slice(/([^:]+)\z/)
      $@.delete_if{|s|/#{Regexp.escape(File.dirname __FILE__)}/ =~ s}
      $@.first.sub!(/([^:]+)\z/){"in `#{name}='"}
      $@ << $@.last
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
      self[name] = default_for name if has_default? name
    end
  end

  # @param [Symbol] method
  def __compare_all__(other, method)
    instance_of?(other.class) && \
    each_pair.all?{|k, v|v.__send__ method, other[k]}
  end
  
  # @endgroup
end; end