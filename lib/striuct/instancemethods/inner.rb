class Striuct; module InstanceMethods

  # @group Use Only Inner

  private

  def _get(name)
    autonym = autonym_for_name name
    value = @db[autonym]
  
    if safety_getter?(autonym) and !accept?(autonym, value)
      raise ::Validation::InvalidReadingError,
            "#{value.inspect} is deficient for #{name} in #{self.class}"
    end

    value
  end

  def _set(name, value)
    raise "can't modify frozen #{self.class}" if frozen?
    autonym = autonym_for_name name
    raise "can't modify locked member #{name}" if lock? autonym

    if has_adjuster? autonym
      begin
        value = instance_exec value, &adjuster_for(autonym)
      rescue Exception
        raise ::Validation::UnmanagebleError
      end
    end

    if safety_setter?(autonym) and !accept?(autonym, value)
      raise ::Validation::InvalidWritingError,
            "#{value.inspect} is deficient for #{name} in #{self.class}"
    end

    if inference? autonym
      self.class.__send__ :_found_family!, self, autonym, value
    end
    
    @db[autonym] = value
  rescue ::Validation::InvalidError
    unless /in \[\]=/ =~ caller[1].slice(/([^:]+)\z/)
      $!.backtrace.delete_if{|s|/#{Regexp.escape(File.dirname __FILE__)}/ =~ s}
      $!.backtrace.first.sub!(/([^:]+)\z/){"in `#{name}='"}
    end
  
    raise
  end

  # @param [Symbol, String, Fixnum] key
  # @return [Symbol] autonym
  def autonym_for_key(key)
    case key
    when Symbol, String
      name = nameable_for key
      if member? name
        return autonym_for_name(name)
      else
        raise NameError
      end
    when Fixnum
      if autonym = _autonyms[key]
        return autonym
      else
        raise IndexError
      end
    else
      raise ArgumentError
    end

    raise 'must not happen'
  end
  
  # @endgroup

end; end
