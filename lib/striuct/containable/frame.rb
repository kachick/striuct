require_relative 'classutil'
require_relative 'eigen/frame'

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

require_relative 'basic'
require_relative 'safety'
require_relative 'handy'
require_relative 'hashlike'
require_relative 'yaml'
require_relative 'inner'