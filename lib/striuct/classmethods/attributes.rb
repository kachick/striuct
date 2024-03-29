# frozen_string_literal: true

class Striuct
  module ClassMethods
    # Attributes for autonym of each member
    class Attributes
      VALUES   = [:condition,
                  :adjuster].freeze

      BOOLEANS = [
        :must,
        :safety_setter,
        :safety_getter
      ].freeze

      def initialize
        @hash = {
          must: false,
          safety_setter: false,
          safety_getter: false
        }
      end

      VALUES.each do |role|
        define_method :"with_#{role}?" do
          @hash.key?(role)
        end

        define_method role do
          @hash.fetch(role)
        end
      end

      def condition=(condition)
        unless Eqq.pattern?(condition)
          raise TypeError, 'wrong object for condition'
        end

        @hash[:condition] = condition
      end

      def adjuster=(adjuster)
        unless Striuct.adjustable?(adjuster)
          raise ArgumentError, 'wrong object for adjuster'
        end

        @hash[:adjuster] = adjuster
      end

      BOOLEANS.each do |role|
        define_method :"with_#{role}?" do
          @hash.fetch(role)
        end

        define_method :"#{role}=" do |arg|
          raise TypeError unless arg.equal?(true) || arg.equal?(false)

          @hash[role] = arg
        end
      end

      def with_default?
        @hash.key?(:default_value)
      end

      def default_value
        @hash.fetch(:default_value)
      end

      def default_type
        @hash.fetch(:default_type)
      end

      # @param [Symbol] type - :value / :lazy
      def set_default(value, type)
        raise TypeError unless type.equal?(:value) || type.equal?(:lazy)

        check_default_lazy_proc(value) if type.equal?(:lazy)

        @hash[:default_type] = type
        @hash[:default_value] = value
      end

      def check_default_lazy_proc(proc)
        raise TypeError unless proc.respond_to?(:call)

        arity = proc.arity
        unless arity <= 2
          raise ArgumentError, "wrong number of block parameter #{arity} for 0..2"
        end
      end

      def freeze
        ret = super
        @hash.freeze
        ret
      end

      def dup
        ret = super
        @hash = @hash.dup
        ret
      end

      private

      def initialize_copy(original)
        ret = super(original)
        @hash = @hash.dup
        ret
      end
    end

    private_constant :Attributes
  end
end
