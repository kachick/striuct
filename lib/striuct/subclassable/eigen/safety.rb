class Striuct; module Subclassable; module Eigen
  # @group Struct+ Safety
  
  # @param [Symbol, String] name
  # inference checker is waiting yet
  def inference?(name)
    name = originalkey_for(keyable_for name)

    @inferences.has_key? name
  end

  # @param [Symbol, String] name
  def has_condition?(name)
    name = originalkey_for(keyable_for name)

    @conditions.has_key?(name)
  end
  
  alias_method :restrict?, :has_condition?

  # @param [Symbol, String] name
  # @param [Object] value
  # @param [Subclass] context - expect own instance
  # value can set the member space
  def sufficient?(name, value, context=nil)
    name = originalkey_for(keyable_for name)

    if restrict? name
      pass? value, condition_for(name), context
    else
      true
    end
  end
  
  alias_method :accept?, :sufficient?
  alias_method :valid?, :sufficient?
  
  # @param [Object] name
  # accpeptable the name into own member, under protect level of runtime
  def cname?(name)
    _check_safety_naming(keyable_for name){|r|r}
  rescue Exception
    false
  end
  
  def closed?
    [@names, @flavors, @defaults, @aliases].any?(&:frozen?)
  end

  # @endgroup
end; end; end