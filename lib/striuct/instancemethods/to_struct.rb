class Striuct; module InstanceMethods 

  # @group To Ruby's Struct
  
  # @return [Struct]
  def to_struct
    self.class.to_struct_class.new(*values)
  end

  # @endgroup

end; end