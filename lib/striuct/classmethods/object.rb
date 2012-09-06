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
  
  def inherited(subclass)
    autonyms = @autonyms.dup
    attributes = [@conditions, @adjusters, @defaults, @inferences, @aliases, @setter_validations, @getter_validations].map(&:dup)
    protect_level = @protect_level
    
    subclass.class_eval do
      original_inherited subclass
      
      @autonyms = autonyms
      @conditions, @adjusters, @defaults, @inferences, @aliases, @setter_validations, @getter_validations = *attributes
      @protect_level = protect_level
    end
  end
     
  def initialize_copy(original)
    ret = super original
    @autonyms, @adjusters, @defaults, @aliases,
    @setter_validations, @getter_validations,
    @conditions, @inferences    = 
    *__floating_attributes__.map(&:dup)
    ret
  end

  def __floating_attributes__
    [@autonyms, @adjusters, @defaults, @aliases,
     @setter_validations, @getter_validations,
     @conditions, @inferences]
  end

  # @endgroup

end; end
