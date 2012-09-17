class Striuct; module InstanceMethods

  # @group Behavior under Values

  # @param [Integer, #to_int, Range] _keys
  # @return [Array]
  def values_at(*_keys)
    [].tap {|r|
      _keys.each do |key|
        case key
        when ->v{v.respond_to? :to_int}
          r << fetch_for_index(key)
        when Range
          key.each do |idx|
            raise TypeError unless idx.respond_to? :to_int

            r << fetch_for_index(idx)
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
    
    self
  end

  # @endgroup

end; end
