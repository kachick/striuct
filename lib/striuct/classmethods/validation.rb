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

  # @param [Symbol, String] name
  def condition_for(name)
    return nil unless has_condition? name
    autonym = autonym_for_member name

    _attributes_for(autonym).condition
  end

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
