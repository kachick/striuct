require_relative 'subscript'

class Striuct; module InstanceMethods

  # @group Like Ruby's Hash
  
  alias_method :fetch, :[]
  
  # @return [Hash]
  def to_h(reject_no_assign=false)
    return @db.dup if reject_no_assign

    {}.tap {|h|
      each_pair do |k, v|
        h[k] = v
      end
    }
  end

  def has_value?(value)
    @db.has_value? value
  end

  alias_method :value?, :has_value?

  # keep truthy only (unassign falsy member)
  # @yield [name, value]
  # @yieldparam [Symbol] name
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
  # @yieldparam [Symbol] name
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
  # @yieldparam [Symbol] name
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
  # @yieldparam [Symbol] name
  # @return [Enumerator]
  def delete_if(&block)
    raise "can't modify frozen #{self.class}" if frozen?
    return to_enum(__method__) unless block_given?

    reject!(&block)
    self
  end

  # @param [Symbol, String] name
  # @return [Array] e.g [name, value]
  def assoc(name)
    name = autonym_for name

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
  # @yieldparam [Symbol] name
  # @return [Striuct]
  def select(&block)
    return to_enum(__method__) unless block_given?

    dup.tap {|r|r.select!(&block)}
  end

  # @see #reject!
  # @yield [name, value]
  # @yieldparam [Symbol] name
  # @return [Striuct]
  def reject(&block)
    return to_enum(__method__) unless block_given?

    dup.tap {|r|r.reject!(&block)}
  end

  # @endgroup

end; end