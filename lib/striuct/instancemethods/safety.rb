# frozen_string_literal: true

class Striuct
  module InstanceMethods
    # @group Safety

    # freezed, fixed familiar members, all members passed any condition
    def secure?
      (frozen? || all_locked?) && self.class.closed? && strict?
    end

    # @endgroup
  end
end
