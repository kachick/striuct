require_relative 'containable/classutil'
require_relative 'containable/eigen'

class Striuct

  # @author Kenichi Kamiya
  module Containable
    extend ClassUtil
    include Enumerable

    class SpecificContainer
      attr_reader :value

      def initialize(value)
        @value = value
      end
    end
    
    if respond_to? :private_constant
      private_constant :SpecificContainer
    end

    class << self
      private

      def included(klass)
        klass.extend Eigen
      end
    end
  end

end

require_relative 'containable/basic'
require_relative 'containable/safety'
require_relative 'containable/handy'
require_relative 'containable/hashlike'
require_relative 'containable/inner'