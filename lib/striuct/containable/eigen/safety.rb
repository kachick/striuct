class Striuct; module Containable; module Eigen
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