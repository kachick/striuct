class Striuct; module InstanceMethods 

  # @group Cast

  # @return [self]
  def to_striuct
    self
  end

  # @return [Struct]
  def to_struct
    self.class.to_struct_class.new(*values)
  end
  
  # @return [Hash]
  def to_h(reject_no_assign=false)
    return @db.dup if reject_no_assign

    {}.tap {|h|
      each_pair do |autonym, val|
        h[autonym] = val
      end
    }
  end
  
  # @return [Array]
  def values
    each_value.to_a
  end
  
  alias_method :to_a, :values

  # @endgroup

end; end