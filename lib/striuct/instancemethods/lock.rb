class Striuct; module InstanceMethods

  # @group Lock
  
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
      autonyms.each do |autonym|
        @locks[autonym] = true
      end
    else
      __subscript__(key){|autonym|@locks[autonym] = true}
    end

    self
  end
  
  # @see #lock
  def lock?(key=true)
    if key.equal? true
      autonyms.all?{|autonym|@locks[autonym]}
    else
      __subscript__(key){|autonym|@locks[autonym]} || false
    end
  end
  
  private
  
  def unlock(key=true)
    raise "can't modify frozen #{self.class}" if frozen?
    
    if key.equal? true
      @locks.clear
    else
      __subscript__(key){|autonym|@locks.delete autonym}
    end

    self
  end

  # @endgroup

end; end