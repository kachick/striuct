# frozen_string_literal: true

class Striuct
  module ClassMethods
    # @group Length/Size

    # @return [Integer]
    def length
      @autonyms.length
    end

    alias_method :size, :length

    # @endgroup
  end; end
