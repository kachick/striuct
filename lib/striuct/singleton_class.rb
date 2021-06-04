# frozen_string_literal: true

class Striuct
  class << self
    alias_method :new_instance, :new
    private :new_instance

    # @param [Symbol, String] autonyms
    # @yieldreturn [Class]
    # @return [Class]
    def new(*autonyms, &block)
      # warning for Ruby's Struct.new user
      first = autonyms.first
      if first.instance_of?(String) && /\A[A-Z]/ =~ first
        warn("no define constant first-arg(#{first}), the Struct behavior is not supported in Striuct")
      end

      Class.new(self) {
        autonyms.each do |autonym|
          add_member autonym
        end

        class_eval(&block) if block
      }
    end

    # @yieldreturn [Class] (see Striuct.new) - reject floating class
    # @return [void]
    def define(&block)
      raise ArgumentError, 'block not supplied' unless block

      new(&block).tap { |subclass|
        subclass.class_eval {
          raise 'not yet finished' if @autonyms.empty?

          close
        }
      }
    end

    # Return `true` if given object is sufficient as an adjuster role
    def adjustable?(object)
      case object
      when Proc
        object.arity == 1
      else
        if object.respond_to?(:to_proc)
          object.to_proc.arity == 1
        else
          false
        end
      end
    end

    private

    def inherited(subclass)
      ret = super(subclass)

      subclass.class_eval {
        extend ClassMethods
        include Enumerable
        extend Eqq::Buildable
        include InstanceMethods

        _init
      }

      ret
    end
  end
end
