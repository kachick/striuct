class Striuct; module InstanceMethods 

  # @group Default Value
  
  # @param [Symbol, String] name
  def default?(name)
    name = autonym_for name

    default_for(name) == self[name]
  end

  # @endgroup

end; end