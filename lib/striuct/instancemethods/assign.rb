class Striuct; module InstanceMethods 

  # @group Assign / Unassign
  
  # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
  def assign?(key)
    @db.has_key? autonym_for_key(key)
  end
  
  # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
  # @return value / nil - value assigned under the key
  def unassign(key)
    _check_frozen
    _check_locked key
    
    @db.delete autonym_for_key(key)
  end
  
  alias_method :delete_at, :unassign

  # true if all members are not yet assigned
  def empty?
    _autonyms.none?{|autonym|@db.has_key? autonym}
  end

  # @endgroup

end; end