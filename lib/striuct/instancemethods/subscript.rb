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

  # @endgroup

end; end
