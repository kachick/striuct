class Striuct; module InstanceMethods

  # @group Setter

  # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
  # @return value
  def []=(key, value)
    autonym = autonym_for_key key
    _set autonym, value
  rescue Validation::InvalidWritingError
    $!.set_backtrace([
      "#{$!.backtrace[-1].sub(/[^:]+\z/){''}}in `[#{key.inspect}(#{autonym})]=': #{$!.message}",
      $!.backtrace[-1]
    ])

    raise
  end

  alias_method :assign, :[]=

  private

  # @param [Symbol] autonym - MUST already converted to native autonym
  # @return value
  def _set(autonym, value)
    raise "can't modify frozen #{self.class}" if frozen?
    raise "can't modify locked member #{autonym}" if lock? autonym

    if with_adjuster? autonym
      begin
        value = instance_exec value, &adjuster_for(autonym)
      rescue Exception
        raise ::Validation::UnmanagebleError
      end
    end

    if with_safety_setter?(autonym) and !accept?(autonym, value)
      raise ::Validation::InvalidWritingError,
            "#{value.inspect} is deficient for #{autonym} in #{self.class}"
    end

    if with_inference? autonym
      self.class.__send__ :_found_family, self, autonym, value
    end
    
    @db[autonym] = value
  rescue ::Validation::InvalidError
    unless /in \[\]=/ =~ caller[1].slice(/([^:]+)\z/)
      $!.backtrace.delete_if{|s|/#{Regexp.escape(File.dirname __FILE__)}/ =~ s}
      $!.backtrace.first.sub!(/([^:]+)\z/){"in `#{autonym}='"}
    end
  
    raise
  end

  # @endgroup

end; end
