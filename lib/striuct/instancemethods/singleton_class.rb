class Striuct; module InstanceMethods

  class << self
    
    private
    
    def delegate_class_method(name)
      define_method name do |*args, &block|
        self.class.__send__ name, *args, &block
      end
    end
    
    def delegate_class_methods(name, *names)
      [name, *names].each{|_name|delegate_class_method _name}
    end
    
  end

end; end
