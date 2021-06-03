# frozen_string_literal: true

class Striuct
  module InstanceMethods
    # @group Behavior under Values

    # @param [Integer, #to_int, Range] keys
    # @return [Array]
    def values_at(*keys)
      [].tap { |r|
        keys.each do |key|
          case key
          when ->v { v.respond_to?(:to_int) }
            r << fetch_by_index(key)
          when Range
            key.each do |idx|
              raise TypeError unless idx.respond_to?(:to_int)

              r << fetch_by_index(idx)
            end
          else
            raise TypeError
          end
        end
      }
    end

    # @return [Array]
    # @raise [ArgumentError] if the keys contains an unmatched
    #     key and no block is given
    def fetch_values(*keys, &block)
      keys.map { |key|
        if key?(key)
          fetch_by_key(key)
        else
          if block
            yield
          else
            raise ArgumentError, "`#{key}' is not matched"
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
        _set(autonym_for_index(index), value)
      end

      self
    end

    # @endgroup
  end
end
