# frozen_string_literal: true

class Striuct
  module InstanceMethods
    # @group Enumerative

    # @yield [autonym]
    # @yieldparam [Symbol] autonym - sequential under defined
    # @yieldreturn [self]
    # @return [Enumerator]
    def each_autonym(&block)
      return to_enum(__callee__) { self.class.size } unless block

      self.class.each_autonym(&block)
      self
    end

    alias_method :each_member, :each_autonym

    # @yield [value]
    # @yieldparam [Object] value - sequential under defined
    # @see #each_autonym
    # @yieldreturn [self]
    # @return [Enumerator]
    def each_value
      return to_enum(__callee__) { self.class.size } unless block_given?

      each_autonym { |autonym| yield _get(autonym) }
    end

    alias_method :each, :each_value

    # @yield [autonym, value]
    # @yieldparam [Symbol] autonym
    # @yieldparam [Object] value
    # @yieldreturn [self]
    # @return [Enumerator]
    # @see #each_autonym
    # @see #each_value
    def each_pair
      return to_enum(__callee__) { self.class.size } unless block_given?

      each_autonym { |autonym| yield autonym, _get(autonym) }
    end

    # @yield [index]
    # @yieldparam [Integer] index
    # @yieldreturn [self]
    # @return [Enumerator]
    def each_index
      return to_enum(__callee__) { self.class.size } unless block_given?

      self.class.each_index { |index| yield index }
      self
    end

    # @yield [autonym, index]
    # @yieldparam [Symbol] autonym
    # @yieldparam [Integer] index
    # @yieldreturn [self]
    # @return [Enumerator]
    def each_autonym_with_index
      return to_enum(__callee__) { self.class.size } unless block_given?

      self.class.each_autonym_with_index { |autonym, index| yield autonym, index }
      self
    end

    alias_method :each_member_with_index, :each_autonym_with_index

    # @yield [value, index]
    # @yieldparam [Integer] index
    # @yieldreturn [self]
    # @return [Enumerator]
    def each_value_with_index
      return to_enum(__callee__) { self.class.size } unless block_given?

      each_value.with_index { |value, index| yield value, index }
    end

    alias_method :each_with_index, :each_value_with_index

    # @yield [autonym, value, index]
    # @yieldparam [Symbol] autonym
    # @yieldparam [Integer] index
    # @yieldreturn [self]
    # @return [Enumerator]
    def each_pair_with_index
      return to_enum(__callee__) { self.class.size } unless block_given?

      index = 0
      each_pair do |autonym, value|
        yield autonym, value, index
        index += 1
      end
    end

    # @endgroup
  end; end
