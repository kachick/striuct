# frozen_string_literal: true

class Striuct
  module InstanceMethods
    # @group Cast

    # @return [self]
    def to_striuct
      self
    end

    # @return [Struct]
    def to_struct
      self.class.to_struct_class.new(*values)
    end

    # @param [Boolean] include_no_assign
    # @return [Hash]
    def to_h(include_no_assign=true)
      return @db.dup unless include_no_assign

      each_pair.to_a.to_h
    end

    # @return [Array]
    def values
      each_value.to_a
    end

    alias_method :to_a, :values

    # @endgroup
  end
end
