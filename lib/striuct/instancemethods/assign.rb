require_relative 'subscript'

class Striuct; module InstanceMethods 

  # @group Assign
  
  alias_method :assign, :[]=
  
  # @param [Symbol, String] name
  def assign?(name)
    autonym = autonym_for_name name
    
    @db.has_key? autonym
  end
  
  # @param [Symbol, String, Fixnum] key
  def unassign(key)
    raise "can't modify frozen #{self.class}" if frozen?
    autonym = autonym_for_key key

    @db.delete autonym
  end
  
  alias_method :clear_at, :unassign # obsolute
  alias_method :reset_at, :unassign

  # all members aren't assigned
  def empty?
    _autonyms.none?{|autonym|assign? autonym}
  end

  # @endgroup

end; end
