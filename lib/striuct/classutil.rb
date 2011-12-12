class Striuct


# @author Kenichi Kamiya
module ClassUtil

  private
  
  # @macro delegate_class_method
  def delegate_class_method(name)
    define_method name do |*args, &block|
      self.class.__send__ name, *args, &block
    end
  end
  
  # @macro delegate_class_methods
  def delegate_class_methods(*names)
    raise ArgumentError unless names.length >= 1
    
    names.each{|name|delegate_class_method name}
  end

end


end