class Striuct; module Subclassable
  # @group Struct+ Safety
  
  # see self.class.*args
  delegate_class_methods :restrict?, :has_conditions?, :inference?
  
  # @param [Symbol, String] name
  # @param [Object] *values - no argument and use own
  # passed under any condition
  def sufficient?(name, value=self[name])
    self.class.sufficient? name, value, self
  end
  
  alias_method :accept?, :sufficient?
  alias_method :valid?, :sufficient?

  # all members passed under any condition
  def strict?
    each_pair.all?{|name, value|sufficient? name, value}
  end
  
  # freezed, fixed familar members, all members passed any condition
  def secure?
    frozen? && self.class.closed? && strict?
  end

  # @endgroup
end; end