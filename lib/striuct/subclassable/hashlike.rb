class Striuct; module Subclassable
  # @group HashLike
  
  # @return [Hash]
  def to_h(reject_no_assign=false)
    return @db.dup if reject_no_assign

    {}.tap {|h|
      each_pair do |k, v|
        h[k] = v
      end
    }
  end

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

  def has_value?(value)
    @db.has_value? value
  end

  alias_method :value?, :has_value?

  # @yield [name, value]
  # keep truthy only (unassign falsy member)
  # @see #each_pair
  # @return [Enumerator]
  # @yieldreturn [self]
  # @yieldreturn [nil]
  def select!
    raise "can't modify frozen #{self.class}" if frozen?
    return to_enum(__method__) unless block_given?

    modified = false
    each_pair do |name, value|
      unless yield name, value
        unassign name
        modified = true
      end
    end
    
    modified ? self : nil
  end

  # @see #select!
  # @yield [name, value]
  # @return [Enumerator]
  def keep_if(&block)
    raise "can't modify frozen #{self.class}" if frozen?
    return to_enum(__method__) unless block_given?
    select!(&block)
    self
  end

  # @see #select!
  # keep falsy only (unassign truthy member)
  # @yield [name, value]
  # @return [Enumerator]
  def reject!
    raise "can't modify frozen #{self.class}" if frozen?
    return to_enum(__method__) unless block_given?

    modified = false
    each_pair do |name, value|
      if yield name, value
        unassign name
        modified = true
      end
    end
    
    modified ? self : nil
  end

  # @see #reject!
  # @yield [name, value]
  # @return [Enumerator]
  def delete_if(&block)
    raise "can't modify frozen #{self.class}" if frozen?
    return to_enum(__method__) unless block_given?

    reject!(&block)
    self
  end

  # @param [Symbol, String] name
  # @return [Array] [name, value]
  def assoc(name)
    name = originalkey_for(keyable_for name)

    [name, self[name]]
  end

  # @return [Array] [name, value]
  def rassoc(value)
    each_pair.find{|pair|pair[1] == value}
  end

  # @see Hash#flatten
  # @return [Array]
  def flatten(level=1)
    each_pair.to_a.flatten level
  end

  # @see #select!
  # @yield [name, value]
  # @return [Subclass]
  def select(&block)
    return to_enum(__method__) unless block_given?

    dup.tap {|r|r.select!(&block)}
  end

  # @see #reject!
  # @yield [name, value]
  # @return [Subclass]
  def reject(&block)
    return to_enum(__method__) unless block_given?

    dup.tap {|r|r.reject!(&block)}
  end

  # @endgroup
end; end