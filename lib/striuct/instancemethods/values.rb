class Striuct; module InstanceMethods

  # @group Behavior under Values

  # @param [Fixnum, Range] _keys
  # @return [Array]
  def values_at(*_keys)
    [].tap {|r|
      _keys.each do |key|
        case key
        when Fixnum
          r << self[key]
        when Range
          key.each do |n|
            raise TypeError unless n.instance_of? Fixnum
            r << self[n]
          end
        else
          raise TypeError
        end
      end
    }
  end

  # @return [self]
  def replace_values(*values)
    unless values.size <= size
      raise ArgumentError, "struct size differs (max: #{size})"
    end

    values.each_with_index do |value, index|
      self[index] = value
    end
      
    excess = autonyms.last(size - values.size)
      
    excess.each do |autonym|
      if has_default? autonym
        self[autonym] = (
          value = default_for autonym
          if value.kind_of? DefaultProcHolder
            block = value.value
            args = [self, autonym][0, block.arity]
            block.call(*args)
          else
            value
          end
        )
      end
    end
    
    self
  end

  # @endgroup

end; end
