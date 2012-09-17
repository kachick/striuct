class Striuct; module ClassMethods

  # @group Validation
  
  # @param [Symbol, String] name
  # inference checker is waiting yet
  def inference?(name)
    autonym = autonym_for_member name

    _attributes_for(autonym).inference?
  end

  # @param [Symbol, String] name
  def has_condition?(name)
    autonym = autonym_for_member name

    _attributes_for(autonym).has_condition?
  end
  
  alias_method :restrict?, :has_condition?
  alias_method :has_validator?, :has_condition? # obsolute

  # @param [Symbol, String] name
  def condition_for(name)
    return nil unless has_condition? name
    autonym = autonym_for_member name

    _attributes_for(autonym).condition
  end
  
  alias_method :validator_for, :condition_for # obsolute

  # @param [Symbol, String] name
  def safety_getter?(name)
    autonym = autonym_for_member name

    _attributes_for(autonym).validate_with_getter?
  end
  
  alias_method :safety_reader?, :safety_getter?
  
  # @param [Symbol, String] name
  def safety_setter?(name)
    autonym = autonym_for_member name

    _attributes_for(autonym).validate_with_setter?
  end

  alias_method :safety_writer?, :safety_setter?

  # @endgroup

end; end
