class Striuct; module Subclassable
  # @group Struct+ Safety
  
  # see self.class.*args
  delegate_class_methods :restrict?, :has_condition?, :inference?
  
  # @param [Symbol, String] name
  # @param [Object] *values - no argument and use own
  # passed under any condition
  def sufficient?(name, value=self[name])
    self.class.sufficient? name, value, self
  end
  
  alias_method :accept?, :sufficient?
  alias_method :valid?, :sufficient?

  # all members passed under any condition
  def strict?
    each_pair.all?{|name, value|sufficient? name, value}
  end
  
  # freezed, fixed familar members, all members passed any condition
  def secure?
    (frozen? || lock?) && self.class.closed? && strict?
  end

  # @overload lock(key)
  #   lock a setter for key 
  #   @param [Symbol, String, Fixnum] key
  # @overload lock(true)
  #   lock setters for all members
  #   @param [true] true
  # @return [self]
  def lock(key=true)
    raise "can't modify frozen #{self.class}" if frozen?
    
    if key.equal? true
      names.each do |name|
        @locks[name] = true
      end
    else
      __subscript__(key){|name|@locks[name] = true}
    end

    self
  end

  # @see #lock
  def lock?(key=true)
    if key.equal? true
      names.all?{|name|@locks[name]}
    else
      __subscript__(key){|name|@locks[name]} || false
    end
  end
  
  private
  
  def unlock(key=true)
    raise "can't modify frozen #{self.class}" if frozen?
    
    if key.equal? true
      @locks.clear
    else
      __subscript__(key){|name|@locks.delete name}
    end

    self
  end

  # @endgroup
end; end