class Striuct; module InstanceMethods

  # @group Subscript

  # @param [Symbol, String, Fixnum] key
  def [](key)
    __subscript__(key){|autonym|__get__ autonym}
  end
  
  # @param [Symbol, String, Fixnum] key
  # @param [Object] value
  # @return [value]
  def []=(key, value)
    true_name = nil
    __subscript__(key){|autonym|
      true_name = autonym
      __set__ autonym, value
    }
  rescue Validation::InvalidWritingError
    $!.set_backtrace([
      "#{$!.backtrace[-1].sub(/[^:]+\z/){''}}in `[#{key.inspect}(#{true_name})]=': #{$!.message}",
      $!.backtrace[-1]
    ])

    raise
  end

  private

  # @param [Symbol, String, Fixnum] key
  # @yield [autonym]
  # @yieldparam [Symbol] autonym
  def __subscript__(key)
    case key
    when Symbol, String
      name = keyable_for key
      if member? name
        yield autonym_for(name)
      else
        raise NameError
      end
    when Fixnum
      if autonym = autonyms[key]
        yield autonym
      else
        raise IndexError
      end
    else
      raise ArgumentError
    end
  end

  # @endgroup

end; end
