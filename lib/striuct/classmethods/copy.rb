class Striuct; module ClassMethods

  # @group Basic Methods for Ruby's Object

  # @return [Module]
  def dup
    autonyms = @autonyms.dup
    aliases  = @aliases.dup
    attributes = @attributes.deep_dup

    super.tap {|ret|
      ret.instance_eval do
        @autonyms = autonyms
        @aliases = aliases
        @attributes = attributes
      end
    }
  end

  # @return [Module]
  def clone
    ret = super
    ret.__send__ :close if closed?
    ret
  end

  private
  
  def inherited(subclass)
    autonyms = @autonyms.dup
    aliases  = @aliases.dup
    attributes = @attributes.deep_dup
    conflict_management = @conflict_management_level
    
    subclass.class_eval do
      original_inherited subclass
      
      @autonyms = autonyms
      @aliases = aliases
      @attributes = attributes
      @conflict_management_level = conflict_management
    end
  end
     
  def initialize_copy(original)
    ret = super original
    @autonyms = @autonyms.dup
    @aliases = @aliases.dup
    @attributes = @attributes.deep_dup
    ret
  end

  # @endgroup

end; end
