require_relative 'instancemethods'

class Striuct

  class << self

    # @group Constructor
    
    alias_method :new_instance, :new
    private :new_instance
    
    # @param [Symbol, String] autonyms
    # @return [Class]
    def new(*autonyms, &block)
      # warning for Ruby's Struct.new user
      first = autonyms.first
      if first.instance_of?(String) and /\A[A-Z]/ =~ first
        warn "no define constant #{first}"
      end

      Class.new self do
        autonyms.each do |autonym|
          member autonym
        end

        class_eval(&block) if block_given?
      end
    end

    # @yieldreturn [Class] (see Striuct.new) - reject floating class
    # @return [void]
    def define(&block)
      raise ArgumentError, 'must with block' unless block_given?

      new(&block).tap do |subclass|
        subclass.instance_eval do
          raise 'not yet finished' if autonyms.empty?
          close
        end
      end
    end

    # @groupend

    private
    
    alias_method :original_inherited, :inherited
    
    def inherited(subclass)
      attributes = (
        if equal? ::Striuct
          [[], {}, {}, {}, {}, {}, {}, {}, :prevent]
        else
          [
           *[
             @names, @conditions, @adjusters, @defaults,
             @inferences, @aliases, @setter_validations,
             @getter_validations
            ].map(&:dup), @protect_level
          ]
        end
      )
      
      eigen = self

      subclass.class_eval do
        original_inherited subclass

        if ::Striuct.equal? eigen
          extend ClassMethods
          include Enumerable
          include InstanceMethods
        end
        
        @names, @conditions, @adjusters, @defaults,
        @inferences, @aliases, @setter_validations,
        @getter_validations, @protect_level = *attributes
        
        singleton_class.instance_eval do
          define_method :initialize_copy do |original|
            @names, @adjusters, @defaults, @aliases,
            @setter_validations, @getter_validations = 
            *[@names, @adjusters, @defaults, @aliases,
              @setter_validations, @getter_validations].map(&:dup)
            @conditions, @inferences = @conditions.dup, @inferences.dup
          end
        end
      end
    end

  end

end
