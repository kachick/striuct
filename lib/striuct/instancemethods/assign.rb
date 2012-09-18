class Striuct; module InstanceMethods 

  # @group Assign / Unassign
  
  # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
  def assign?(key)
    autonym = autonym_for_key key
    
    @db.has_key? autonym
  end
  
  # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
  # @return value / nil - value assigned under the key
  def unassign(key)
    raise "can't modify frozen #{self.class}" if frozen?
    
    autonym = autonym_for_key key
    raise "can't modify locked member #{autonym}" if lock? autonym

    @db.delete autonym
  end
  
  alias_method :delete_at, :unassign

  # true if all members are not yet assigned
  def empty?
    _autonyms.none?{|autonym|@db.has_key? autonym}
  end

  # @endgroup

end; end
