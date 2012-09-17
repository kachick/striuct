class Striuct; module InstanceMethods 

  # @group Default Value
  
  # @param [Symbol, String] name
  def default?(name)
    autonym = autonym_for_member name

    default_for(autonym) == fetch_for_autonym(autonym)
  end

  # @endgroup

end; end
