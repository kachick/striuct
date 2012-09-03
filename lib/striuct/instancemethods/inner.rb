class Striuct; module InstanceMethods

  # @group Use Only Inner

  private

  def __get__(name)
    autonym = autonym_for name
    value = @db[autonym]
  
    if safety_getter?(autonym) and !accept?(autonym, value)
      raise ::Validation::InvalidReadingError,
            "#{value.inspect} is deficient for #{name} in #{self.class}"
    end

    value
  end

  def __set__(name, value)
    raise "can't modify frozen #{self.class}" if frozen?
    autonym = autonym_for name
    raise "can't modify locked member #{name}" if lock? autonym

    if has_flavor? autonym
      begin
        value = instance_exec value, &flavor_for(autonym)
      rescue Exception
        raise ::Validation::UnmanagebleError
      end
    end

    if safety_setter?(autonym) and !accept?(autonym, value)
      raise ::Validation::InvalidWritingError,
            "#{value.inspect} is deficient for #{name} in #{self.class}"
    end

    if inference? autonym
      self.class.__send__ :__found_family__!, self, autonym, value
    end
    
    @db[autonym] = value
  rescue ::Validation::InvalidError
    unless /in \[\]=/ =~ caller[1].slice(/([^:]+)\z/)
      $!.backtrace.delete_if{|s|/#{Regexp.escape(File.dirname __FILE__)}/ =~ s}
      $!.backtrace.first.sub!(/([^:]+)\z/){"in `#{name}='"}
    end
  
    raise
  end
  
  # @param [Symbol] autonym
  def __clear__(autonym)
    raise "can't modify frozen #{self.class}" if frozen?
    
    @db.delete autonym
  end

  # @endgroup

end; end
