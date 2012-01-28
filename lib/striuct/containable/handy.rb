class Striuct; module Containable 
  # @group Struct + Handy
  
  # see self.class.*args
  delegate_class_methods :has_default?, :default_for, :has_flavor?
  
  # @yield [index] 
  # @yieldparam [Integer] index
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_index(&block)
    return to_enum(__method__) unless block_given?
    self.class.each_index(&block)
    self
  end

  # @yield [value, index]
  # @yieldparam [Integer] index
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_value_with_index(&block)
    return to_enum(__method__) unless block_given?
    each_value.with_index(&block)
    self
  end
  
  alias_method :each_with_index, :each_value_with_index
  
  # @yield [name, value, index]
  # @yieldparam [Symbol] name
  # @yieldparam [Integer] index
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_pair_with_index
    return to_enum(__method__) unless block_given?
    index = 0
    each_pair do |name, value|
      yield name, value, index
      index += 1
    end
    self
  end
  
  # @param [Symbol, String] name
  def assign?(name)
    name = originalkey_for(keyable_for name)
    
    @db.has_key? name
  end
  
  # @param [Symbol, String, Fixnum] key
  def clear_at(key)
    __subscript__(key){|name|__clear__ name}
  end
  
  alias_method :unassign, :clear_at
  alias_method :reset_at, :clear_at

  # @param [Symbol, String] name
  def default?(name)
    name = originalkey_for(keyable_for name)

    default_for(name) == self[name]
  end

  # all members aren't assigned
  def empty?
    each_name.none?{|name|assign? name}
  end

  # @endgroup
end; end