class Striuct; module ClassMethods

  # @group Validation
  
  # @param [Symbol, String] name
  # inference checker is waiting yet
  def inference?(name)
    name = autonym_for name

    @inferences.has_key? name
  end

  # @param [Symbol, String] name
  def has_validator?(name)
    name = autonym_for name

    @conditions.has_key?(name)
  end
  
  alias_method :has_condition?, :has_validator?
  alias_method :restrict?, :has_validator?
  
  # @param [Symbol, String] name
  def validator_for(name)
    _condition_for autonym_for(name)
  end
  
  alias_method :condition_for, :validator_for

  # @param [Symbol, String] name
  def safety_getter?(name)
    name = autonym_for name

    @getter_validations.has_key?(name)
  end
  
  alias_method :safety_reader?, :safety_getter?
  
  # @param [Symbol, String] name
  def safety_setter?(name)
    name = autonym_for name

    @setter_validations.has_key?(name)
  end

  alias_method :safety_writer?, :safety_setter?

  private
  
  def _condition_for(name)
    @conditions[name]
  end

  # @endgroup

end; end