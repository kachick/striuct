class Striuct; module InstanceMethods

  # @group Subscript

  # @param [Symbol, String, Fixnum] key
  def [](key)
    _get _autonym_for_key(key)
  end
  
  # @param [Symbol, String, Fixnum] key
  # @param [Object] value
  # @return [value]
  def []=(key, value)
    autonym = _autonym_for_key key
    _set autonym, value
  rescue Validation::InvalidWritingError
    $!.set_backtrace([
      "#{$!.backtrace[-1].sub(/[^:]+\z/){''}}in `[#{key.inspect}(#{autonym})]=': #{$!.message}",
      $!.backtrace[-1]
    ])

    raise
  end

  private

  # @param [Symbol, String, Fixnum] key
  # @return [Symbol] autonym
  def _autonym_for_key(key)
    case key
    when Symbol, String
      name = keyable_for key
      if member? name
        return autonym_for(name)
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
