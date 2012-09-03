class Striuct; module ClassMethods

  # @group Enumerative

  # @yield [name] 
  # @yieldparam [Symbol] name - sequential under defined
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_name
    return to_enum(__method__) unless block_given?
    _names.each{|name|yield name}
    self
  end

  alias_method :each_member, :each_name
  alias_method :each_key, :each_name
  
  # @yield [index] 
  # @yieldparam [Integer] Index
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_index
    return to_enum(__method__) unless block_given?
    _names.each_index{|index|yield index}
    self
  end

  # @yield [name, index]
  # @yieldparam [Symbol] name
  # @yieldparam [Integer] index
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_name_with_index
    return to_enum(__method__) unless block_given?
    _names.each_with_index{|name, index|yield name, index}
    self
  end
  
  alias_method :each_member_with_index, :each_name_with_index
  alias_method :each_key_with_index, :each_name_with_index

  # @endgroup

end; end