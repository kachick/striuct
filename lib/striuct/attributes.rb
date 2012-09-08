class Striuct

  # Attributes for each Member(Autonym)
  class Attributes

    VALUES = [:condition, :adjuster].freeze
    BOOLEANS = [
                :inference,
                :validate_with_setter,
                :validate_with_getter
               ].freeze
    
    def initialize
      @hash = {
        inference:            false,
        validate_with_setter: false,
        validate_with_getter: false
      }
    end
    
    VALUES.each do |role|
      define_method "has_#{role}?".to_sym do
        @hash.has_key? role
      end
      
      define_method role do
        @hash.fetch role
      end

      define_method "#{role}=".to_sym do |arg|
        @hash[role] = arg
      end
    end

    BOOLEANS.each do |role|
      define_method "#{role}?".to_sym do
        @hash.fetch role
      end
      
      define_method "#{role}=".to_sym do |arg|
        raise TypeError unless arg.equal?(true) or arg.equal?(false)

        @hash[role] = arg
      end   
    end

    def has_default?
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
