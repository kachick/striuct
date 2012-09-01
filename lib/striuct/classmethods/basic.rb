class Striuct; module ClassMethods
  # @group Basic

  # @return [Array<Symbol>]
  def names
    @names.dup
  end

  alias_method :autonyms, :names
  alias_method :members, :names
  alias_method :keys, :names
  
  # @return [Array<Symbol>]
  def all_members
    @names + @aliases.keys
  end

  def has_member?(name)
    autonym_for name
  rescue Exception
    false
  else
    true
  end
  
  alias_method :member?, :has_member?
  alias_method :has_key?, :has_member?
  alias_method :key?, :has_key?

  # @return [Integer]
  def length
    @names.length
  end
  
  alias_method :size, :length

  # @return [self]
  def freeze
    __stores__.each(&:freeze)
    super
  end

  def dup
    r = super
    @names, @flavors, @defaults, @aliases,
    @setter_validations, @getter_validations = 
    *[@names, @flavors, @defaults, @aliases,
      @setter_validations, @getter_validations].map(&:dup)
    @conditions, @inferences = @conditions.dup, @inferences.dup
    r
  end

  # @endgroup
end; end
