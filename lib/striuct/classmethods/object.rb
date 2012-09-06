class Striuct; module ClassMethods

  # @group Basic Methods for Ruby's Object

  # @return [self]
  def freeze
    __floating_attributes__.each(&:freeze)
    super
  end

  # @return [Class]
  def dup
    r = super
    @autonyms, @adjusters, @defaults, @aliases,
    @setter_validations, @getter_validations,
    @conditions, @inferences    = 
    *__floating_attributes__.map(&:dup)
    r
  end
  
  private
  
  def __floating_attributes__
    [@autonyms, @adjusters, @defaults, @aliases,
     @setter_validations, @getter_validations,
     @conditions, @inferences]
  end

  # @endgroup

end; end
