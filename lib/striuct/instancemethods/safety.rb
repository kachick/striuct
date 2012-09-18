class Striuct; module InstanceMethods

  # @group Safety
  
  # freezed, fixed familar members, all members passed any condition
  def secure?
    (frozen? || all_locked?) && self.class.closed? && strict?
  end

  # @endgroup

end; end