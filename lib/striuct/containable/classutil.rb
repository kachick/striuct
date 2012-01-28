class Striuct; module Containable


# @author Kenichi Kamiya
module ClassUtil

  private
  
  def delegate_class_method(name)
    define_method name do |*args, &block|
      self.class.__send__ name, *args, &block
    end
  end
  
  def delegate_class_methods(*names)
    unless names.length >= 1
      raise ArgumentError, 'wrong number of argument 0 for 1+'
    end
    
    names.each{|name|delegate_class_method name}
  end

end


end; end