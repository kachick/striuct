require 'validation'

class Striuct

  class << self

    # @group Constructor
    
    alias_method :new_instance, :new
    private :new_instance
    
    # @param [Symbol, String] autonyms
    # @yieldreturn [Class]
    # @return [Class]
    def new(*autonyms, &block)
      # warning for Ruby's Struct.new user
      first = autonyms.first
      if first.instance_of?(String) and /\A[A-Z]/ =~ first
        warn "no define constant first-arg(#{first}), the Struct behavior is not supported in Striuct"
      end

      Class.new(self) {
        autonyms.each do |autonym|
          add_member autonym
        end

        class_eval(&block) if block_given?
      }
    end

    # @yieldreturn [Class] (see Striuct.new) - reject floating class
    # @return [void]
    def define(&block)
      raise ArgumentError, 'block not supplied' unless block_given?

      new(&block).tap {|subclass|
        subclass.class_eval {
          raise 'not yet finished' if @autonyms.empty?
          close
        }
      }
    end

    # @groupend

    private
    
    alias_method :original_inherited, :inherited

    def inherited(subclass)
      subclass.class_eval {
        original_inherited subclass

        extend ClassMethods
        include Enumerable
        include Validation
        include InstanceMethods
        
        _init
      }
    end

  end

end
