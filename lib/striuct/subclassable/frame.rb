require_relative 'classutil'
require_relative 'eigen'

class Striuct

  # @author Kenichi Kamiya
  module Subclassable
    extend ClassUtil
    include Enumerable
    
    class << self
      private

      def included(klass)
        klass.extend Eigen
      end
    end
  end

end

require_relative 'instance'