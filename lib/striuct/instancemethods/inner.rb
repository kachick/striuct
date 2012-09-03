class Striuct; module InstanceMethods

  # @group Use Only Inner

  private

  def __get__(name)
    name = autonym_for name
    value = @db[name]
  
    if safety_getter?(name) and !accept?(name, value)
      raise ::Validation::InvalidReadingError,
            "#{value.inspect} is deficient for #{name} in #{self.class}"
    end

    value
  end

  def __set__(name, value)
    raise "can't modify frozen #{self.class}" if frozen?
    name = autonym_for name
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
  
  # @param [Symbol] name
  def __clear__(name)
    raise "can't modify frozen #{self.class}" if frozen?
    
    @db.delete name
  end

  # @endgroup

end; end
