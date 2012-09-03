class Striuct; module InstanceMethods

  # @group Validation
  
  # @param [Symbol, String] name
  # @param [Object] value - no argument and use own
  # passed under any condition
  def sufficient?(name, value=self[name])
    name = autonym_for name
    return true unless restrict? name
    
    _valid? condition_for(name), value
  end
  
  alias_method :accept?, :sufficient?
  alias_method :valid?, :sufficient?

  # all members passed under any condition
  def strict?
    each_pair.all?{|name, value|sufficient? name, value}
  end

  # @endgroup

end; end