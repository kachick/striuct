require_relative 'subscript'

class Striuct; module InstanceMethods 

  # @group Assign
  
  alias_method :assign, :[]=
  
  # @param [Symbol, String] name
  def assign?(name)
    autonym = autonym_for name
    
    @db.has_key? autonym
  end
  
  # @param [Symbol, String, Fixnum] key
  def clear_at(key)
    raise "can't modify frozen #{self.class}" if frozen?
    autonym = _autonym_for_key key

    @db.delete autonym
  end
  
  alias_method :unassign, :clear_at
  alias_method :reset_at, :clear_at

  # all members aren't assigned
  def empty?
    _autonyms.none?{|autonym|assign? autonym}
  end

  # @endgroup

end; end
