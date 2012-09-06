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
          add_member autonym
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
    alias_method :original_initialize_copy, :initialize_copy

    def inherited(subclass)
      if equal? ::Striuct
        head_inherited subclass
        subclass.singleton_class.__send__ :undef_method, :head_inherited
      else
        tail_inherited subclass
      end
    end

    def head_inherited(subclass)
      subclass.class_eval do
        original_inherited subclass

        extend ClassMethods
        include Enumerable
        include InstanceMethods
        
        @autonyms = []
        @conditions, @adjusters, @defaults, @inferences, @aliases, @setter_validations, @getter_validations = \
          {}, {}, {}, {}, {}, {}, {}
        @protect_level = :prevent

        singleton_class.__send__ :define_initialize_copy
      end
    end
    
    def tail_inherited(subclass)
      autonyms = @autonyms.dup
      attributes = [@conditions, @adjusters, @defaults, @inferences, @aliases, @setter_validations, @getter_validations].map(&:dup)
      protect_level = @protect_level
      
      subclass.class_eval do
        original_inherited subclass
        
        @autonyms = autonyms
        @conditions, @adjusters, @defaults, @inferences, @aliases, @setter_validations, @getter_validations = *attributes
        @protect_level = protect_level
        
        singleton_class.__send__ :define_initialize_copy
      end
    end

    # For Singleton Class's macro
    class << self
      
      private
    
      def define_initialize_copy
        define_method :initialize_copy do |original|
          ret = original_initialize_copy original
          @autonyms = @autonyms.dup
          @conditions, @adjusters, @defaults, @inferences, @aliases, @setter_validations, @getter_validations = \
          [@conditions, @adjusters, @defaults, @inferences, @aliases, @setter_validations, @getter_validations].map(&:dup)
          ret
        end
      end
    
    end

  end

end
