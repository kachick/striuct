class Striuct

  # Attributes for each Member(Autonym)
  class Attributes

    VALUES   = [ :condition,
                 :adjuster  ].freeze

    BOOLEANS = [ :inference,
                 :safety_setter,
                 :safety_getter ].freeze
    
    def initialize
      @hash =  { inference:     false,
                 safety_setter: false,
                 safety_getter: false }
    end
    
    VALUES.each do |role|
      define_method :"with_#{role}?" do
        @hash.has_key? role
      end
      
      define_method role do
        @hash.fetch role
      end
    end

    def condition=(condition)
      unless ::Validation.conditionable? condition
        raise TypeError, 'wrong object for condition' 
      end

      @hash[:condition] = condition
    end

    def adjuster=(adjuster)
      unless ::Validation.adjustable? adjuster
        raise ArgumentError, "wrong number of block argument #{arity} for 1"
      end

      @hash[:adjuster] = adjuster
    end

    BOOLEANS.each do |role|
      define_method :"with_#{role}?" do
        @hash.fetch role
      end
      
      define_method "#{role}=".to_sym do |arg|
        raise TypeError unless arg.equal?(true) or arg.equal?(false)

        @hash[role] = arg
      end   
    end

    def with_default?
      @hash.has_key? :default_value
    end

    def default_value
      @hash.fetch :default_value
    end

    def default_type
      @hash.fetch :default_type
    end

    # @param [Symbol] type - :value / :lazy
    def set_default(value, type)
      raise TypeError unless type.equal?(:value) or type.equal?(:lazy)
      check_default_lazy_proc value if type.equal?(:lazy)
      
      @hash[:default_type] = type
      @hash[:default_value] = value
    end

    def check_default_lazy_proc(_proc)
      raise TypeError unless _proc.respond_to? :call
      arity = _proc.arity
      unless arity <= 2
        raise ArgumentError, "wrong number of block parameter #{arity} for 0..2"
      end
    end

    def freeze
      ret = super
      @hash.freeze
      ret
    end

    def dup
      ret = super
      @hash = @hash.dup
      ret
    end
    
    private
    
    def initialize_copy(original)
      ret = super original
      @hash = @hash.dup
      ret
    end

  end

  if respond_to? :private_constant
    private_constant :Attributes
  end

end
