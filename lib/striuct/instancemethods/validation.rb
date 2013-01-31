class Striuct; module InstanceMethods

  # @group Validation
  
  # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
  # @param value
  # true if passed under any condition
  def accept?(key, value)
    autonym = autonym_for_key key
    return true unless restrict? autonym
  
    begin  
      _valid? condition_for(autonym), value
    rescue Exception
      false
    end
  end

  # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
  # @param value - if no argument and use current assigned value
  # true if passed under any condition
  def sufficient?(key, value=self[key])
    accept? key, value
  end

  alias_method :valid?, :sufficient?

  # all members passed under any condition
  def strict?
    each_pair.all?{|autonym, value|sufficient? autonym, value}
  end

  # @endgroup

end; end