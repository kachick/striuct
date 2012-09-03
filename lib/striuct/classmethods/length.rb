class Striuct; module ClassMethods

  # @group Length/Size

  # @return [Integer]
  def length
    @names.length
  end
  
  alias_method :size, :length

  # @endgroup

end; end
