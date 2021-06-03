# frozen_string_literal: true

class Striuct
  module ClassMethods
    # @group Basic Methods for Ruby's Object

    # @return [Class]
    def clone
      ret = super
      ret.__send__(:close_member) if closed?
      ret
    end

    # @return [Class]
    def dup
      copy_variables!(super)
    end

    private

    def inherited(subclass)
      ret = super(subclass)
      copy_variables!(subclass)
      ret
    end

    def initialize_copy(original)
      ret = super(original)
      @autonyms = @autonyms.dup
      @aliases = @aliases.dup
      @attributes = @attributes.deep_dup
      ret
    end

    # @return [familiar_class]
    def copy_variables!(familiar_class)
      autonyms = @autonyms.dup
      aliases  = @aliases.dup
      attributes = @attributes.deep_dup
      conflict_management = @conflict_management_level

      familiar_class.class_eval do
        @autonyms = autonyms
        @aliases = aliases
        @attributes = attributes
        @conflict_management_level = conflict_management
      end

      familiar_class
    end

    # @endgroup
  end
end
