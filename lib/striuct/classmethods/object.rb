class Striuct; module ClassMethods

  # @group Basic Methods for Ruby's Object

  # @return [self]
  def freeze
    [@autonyms, @aliases, @attributes].each(&:freeze)
    super
  end

  # @return [Class]
  def dup
    ret = super
    @autonyms = @autonyms.dup
    @aliases = @aliases.dup
    @attributes = @attributes.deep_dup
    ret
  end
  
  private
  
  def inherited(subclass)
    autonyms = @autonyms.dup
    aliases  = @aliases.dup
    attributes = @attributes.deep_dup
    protect_level = @protect_level
    
    subclass.class_eval do
      original_inherited subclass
      
      @autonyms = autonyms
      @aliases = aliases
      @attributes = attributes
      @protect_level = protect_level
    end
  end
     
  def initialize_copy(original)
    ret = super original
    @autonyms = @autonyms.clone
    @aliases = @aliases.clone
    @attributes = @attributes.deep_clone
    ret
  end

  # @endgroup

end; end
