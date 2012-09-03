class Striuct; module ClassMethods

  # @group Basic Methods for Ruby's Object

  # @return [self]
  def freeze
    __stores__.each(&:freeze)
    super
  end

  # @return [Class]
  def dup
    r = super
    @autonyms, @adjusters, @defaults, @aliases,
    @setter_validations, @getter_validations = 
    *[@autonyms, @adjusters, @defaults, @aliases,
      @setter_validations, @getter_validations].map(&:dup)
    @conditions, @inferences = @conditions.dup, @inferences.dup
    r
  end

  # @endgroup

end; end