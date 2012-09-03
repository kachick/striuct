class Striuct; module InstanceMethods

  # @group Compare with other
  
  # @return [Boolean]
  def ==(other)
    __compare_all__ other, :==
  end

  alias_method :===, :==
  
  def eql?(other)
    __compare_all__ other, :eql?
  end

  # @return [Integer]
  def hash
    @db.hash
  end

  private  

  # @param [Symbol] method
  def __compare_all__(other, method)
    instance_of?(other.class) && \
    each_pair.all?{|k, v|v.__send__ method, other[k]}
  end

  # @endgroup

end; end
