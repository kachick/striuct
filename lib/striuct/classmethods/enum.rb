# frozen_string_literal: true

class Striuct
  module ClassMethods
    # @group Enumerative

    # @yield [autonym]
    # @yieldparam [Symbol] autonym - sequential under defined
    # @yieldreturn [Class] self
    # @return [Enumerator]
    def each_autonym
      return to_enum(__callee__) { size } unless block_given?

      @autonyms.each { |autonym| yield autonym }
      self
    end

    alias_method :each_member, :each_autonym

    # @yield [index]
    # @yieldparam [Integer] Index
    # @yieldreturn [Class] self
    # @return [Enumerator]
    def each_index
      return to_enum(__callee__) { size } unless block_given?

      @autonyms.each_index { |index| yield index }
      self
    end

    # @yield [autonym, index]
    # @yieldparam [Symbol] autonym
    # @yieldparam [Integer] index
    # @yieldreturn [Class] self
    # @return [Enumerator]
    def each_autonym_with_index
      return to_enum(__callee__) { size } unless block_given?

      @autonyms.each_with_index { |autonym, index| yield autonym, index }
      self
    end

    alias_method :each_member_with_index, :each_autonym_with_index

    # @endgroup
  end; end
