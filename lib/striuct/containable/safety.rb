class Striuct; module Containable
  # @group Struct+ Safety
  
  # see self.class.*args
  delegate_class_methods :restrict?, :has_condition?,
    :safety_getter?, :safety_reader?, :safety_setter?, :safty_writer?, :inference?

  # @param [Object] value
  # @param [Proc, Method, #===] condition
  def pass?(value, condition)
    case condition
    when Conditions::ANYTHING
      true
    when Proc
      instance_exec value, &condition
    when Method
      condition.call value
    else
      condition === value
    end ? true : false
  end

  # @param [Symbol, String] name
  # @param [Object] value - no argument and use own
  # passed under any condition
  def sufficient?(name, value=self[name])
    name = originalkey_for(keyable_for name)
    return true unless restrict? name
    
    pass? value, condition_for(name)
  end
  
  alias_method :accept?, :sufficient?
  alias_method :valid?, :sufficient?

  # all members passed under any condition
  def strict?
    each_pair.all?{|name, value|sufficient? name, value}
  end
  
  # freezed, fixed familar members, all members passed any condition
  def secure?
    (frozen? || lock?) && self.class.closed? && strict?
  end

  # @overload lock(key)
  #   lock a setter for key 
  #   @param [Symbol, String, Fixnum] key
  # @overload lock(true)
  #   lock setters for all members
  #   @param [true] true
  # @return [self]
  def lock(key=true)
    raise "can't modify frozen #{self.class}" if frozen?
    
    if key.equal? true
      names.each do |name|
        @locks[name] = true
      end
    else
      __subscript__(key){|name|@locks[name] = true}
    end

    self
  end

  # @see #lock
  def lock?(key=true)
    if key.equal? true
      names.all?{|name|@locks[name]}
    else
      __subscript__(key){|name|@locks[name]} || false
    end
  end
  
  private
  
  def unlock(key=true)
    raise "can't modify frozen #{self.class}" if frozen?
    
    if key.equal? true
      @locks.clear
    else
      __subscript__(key){|name|@locks.delete name}
    end

    self
  end

  # @endgroup
end; end