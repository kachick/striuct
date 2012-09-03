class Striuct; module InstanceMethods 

  # @group Enumerative

  # @yield [name] 
  # @yieldparam [Symbol] name - sequential under defined
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_name(&block)
    return to_enum(__method__) unless block_given?

    self.class.each_name(&block)
    self
  end

  alias_method :each_member, :each_name
  alias_method :each_key, :each_name

  # @yield [value]
  # @yieldparam [Object] value - sequential under defined
  # @see #each_name
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_value
    return to_enum(__method__) unless block_given?
  
    each_member{|member|yield self[member]}
  end
  
  alias_method :each, :each_value

  # @yield [name, value]
  # @yieldparam [Symbol] name
  # @yieldparam [Object] value
  # @yieldreturn [self]
  # @return [Enumerator]
  # @see #each_name
  # @see #each_value 
  def each_pair
    return to_enum(__method__) unless block_given?

    each_name{|name|yield name, self[name]}
  end

  # @yield [index] 
  # @yieldparam [Integer] index
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_index
    return to_enum(__method__) unless block_given?

    self.class.each_index{|index|yield index}
    self
  end

  # @yield [name, index]
  # @yieldparam [Symbol] name
  # @yieldparam [Integer] index
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_name_with_index
    return to_enum(__method__) unless block_given?

    self.class.each_name_with_index{|name, index|yield name, index}
    self
  end

  alias_method :each_member_with_index, :each_name_with_index
  alias_method :each_key_with_index, :each_name_with_index

  # @yield [value, index]
  # @yieldparam [Integer] index
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_value_with_index
    return to_enum(__method__) unless block_given?

    each_value.with_index{|value, index|yield value, index}
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

  # @endgroup

end; end