require_relative 'subscript'

class Striuct; module InstanceMethods 

  # @group Assign
  
  alias_method :assign, :[]=
  
  # @param [Symbol, String] name
  def assign?(name)
    name = autonym_for name
    
    @db.has_key? name
  end
  
  # @param [Symbol, String, Fixnum] key
  def clear_at(key)
    __subscript__(key){|name|__clear__ name}
  end
  
  alias_method :unassign, :clear_at
  alias_method :reset_at, :clear_at

  # all members aren't assigned
  def empty?
    each_name.none?{|name|assign? name}
  end

  # @endgroup

end; end