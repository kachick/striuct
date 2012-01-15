class Striuct; module Subclassable; module Eigen
  # @group Struct+ Handy

  # @yield [name] 
  # @yieldparam [Symbol] name - sequential under defined
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_name(&block)
    return to_enum(__method__) unless block_given?
    @names.each(&block)
    self
  end

  alias_method :each_member, :each_name
  alias_method :each_key, :each_name
  
  # @yield [index] 
  # @yieldparam [Integer] Index
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_index(&block)
    return to_enum(__method__) unless block_given?
    @names.each_index(&block)
    self
  end

  # @param [Symbol, String] name
  def has_flavor?(name)
    name = originalkey_for(keyable_for name)

    ! @flavors[name].nil?
  end

  # @param [Symbol, String] name
  def has_default?(name)
    name = originalkey_for(keyable_for name)

    @defaults.has_key? name
  end

  # @endgroup
end; end; end