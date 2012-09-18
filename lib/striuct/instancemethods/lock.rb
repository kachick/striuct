class Striuct; module InstanceMethods

  # @group Lock / Unlock
  
  # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
  # @return [self]
  def lock(key)
    raise "can't modify frozen #{self.class}" if frozen?
    autonym = autonym_for_key key

    @locks[autonym] = true
    self
  end
  
  # @return [self]
  def lock_all
    raise "can't modify frozen #{self.class}" if frozen?
    
    each_autonym do |autonym|
      @locks[autonym] = true
    end
  end

  # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
  def locked?(key)
    autonym = autonym_for_key key
    
    @locks.has_key? autonym
  end
  
  def all_locked?
    _autonyms.all?{|autonym|@locks.has_key? autonym}
  end
  
  private

  # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
  # @return [self]
  def unlock(key)
    raise "can't modify frozen #{self.class}" if frozen?
    autonym = autonym_for_key key
    
    @locks.delete autonym
    self
  end
  
  # @return [self]
  def unlock_all
    raise "can't modify frozen #{self.class}" if frozen?

    @locks.clear
    self
  end

  # @endgroup

end; end
