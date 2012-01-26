require_relative 'subclassable/frame'

class Striuct; class << self
  # @group Constructor
  
  alias_method :new_instance, :new
  private :new_instance
  
  # @param [Symbol, String] *names
  # @return [Class] - with Subclass, Subclass:Eigen
  def new(*names, &block)
    # warning for Ruby's Struct.new user
    first = names.first
    if first.instance_of?(String) and /\A[A-Z]/ =~ first
      warn "no define constant #{first}"
    end

    Class.new self do
      names.each do |name|
        member name
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
        raise 'not yet finished' if members.empty?
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
        [[], {}, {}, {}, {}, {}, :prevent]
      else
        [*[@names, @conditions, @flavors, @defaults,\
        @inferences, @aliases].map(&:dup), @protect_level]
      end
    )
    
    eigen = self

    subclass.class_eval do
      original_inherited subclass
      include Subclassable if ::Striuct.equal? eigen
      
      @names, @conditions, @flavors, @defaults,\
      @inferences, @aliases, @protect_level  = *attributes
      
      singleton_class.instance_eval do
        define_method :initialize_copy do |original|
          @names, @flavors, @defaults, @aliases = 
          *[@names, @flavors, @defaults, @aliases].map(&:dup)
          @conditions, @inferences = @conditions.dup, @inferences.dup
        end
      end
    end
  end
end; end