class Striuct; module ClassMethods

  # @group Basic Methods for Ruby's Object

  # @return [self]
  def freeze
    __stores__.each(&:freeze)
    super
  end

  def dup
    r = super
    @names, @flavors, @defaults, @aliases,
    @setter_validations, @getter_validations = 
    *[@names, @flavors, @defaults, @aliases,
      @setter_validations, @getter_validations].map(&:dup)
    @conditions, @inferences = @conditions.dup, @inferences.dup
    r
  end

  # @endgroup

end; end
