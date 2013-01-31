class Striuct; module InstanceMethods

  # @group Like Ruby's Hash

  def has_value?(value)
    @db.has_value? value
  end

  alias_method :value?, :has_value?

  # keep truthy only (unassign falsy member)
  # @yield [autonym, value]
  # @yieldparam [Symbol] autonym
  # @see #each_pair
  # @return [Enumerator]
  # @yieldreturn [self]
  # @yieldreturn [nil]
  def select!
    raise "can't modify frozen #{self.class}" if frozen?
    return to_enum(__callee__) unless block_given?

    modified = false
    each_pair do |autonym, value|
      unless yield autonym, value
        unassign autonym
        modified = true
      end
    end
    
    modified ? self : nil
  end

  # @see #select!
  # @yield [autonym, value]
  # @yieldparam [Symbol] autonym
  # @return [Enumerator]
  def keep_if(&block)
    raise "can't modify frozen #{self.class}" if frozen?
    return to_enum(__callee__) unless block_given?

    select!(&block)
    self
  end

  # @see #select!
  # keep falsy only (unassign truthy member)
  # @yield [autonym, value]
  # @yieldparam [Symbol] autonym
  # @return [Enumerator]
  def reject!
    raise "can't modify frozen #{self.class}" if frozen?
    return to_enum(__callee__) unless block_given?

    modified = false
    each_pair do |autonym, value|
      if yield autonym, value
        unassign autonym
        modified = true
      end
    end
    
    modified ? self : nil
  end

  # @see #reject!
  # @yield [autonym, value]
  # @yieldparam [Symbol] autonym
  # @return [Enumerator]
  def delete_if(&block)
    raise "can't modify frozen #{self.class}" if frozen?
    return to_enum(__callee__) unless block_given?

    reject!(&block)
    self
  end

  # @param [Symbol, String] name
  # @return [Array] e.g [autonym, value]
  def assoc(name)
    autonym = autonym_for_member name

    [autonym, self[name]]
  end

  # @return [Array] [autonym, value]
  def rassoc(value)
    each_pair.find{|_, val|val == value}
  end

  # @see Hash#flatten
  # @return [Array]
  def flatten(level=1)
    each_pair.to_a.flatten level
  end

  # @see #select!
  # @yield [autonym, value]
  # @yieldparam [Symbol] autonym
  # @return [Striuct]
  def select(&block)
    return to_enum(__callee__) unless block_given?

    dup.tap {|r|r.select!(&block)}
  end

  # @see #reject!
  # @yield [autonym, value]
  # @yieldparam [Symbol] autonym
  # @return [Striuct]
  def reject(&block)
    return to_enum(__callee__) unless block_given?

    dup.tap {|r|r.reject!(&block)}
  end

  # @endgroup

end; end