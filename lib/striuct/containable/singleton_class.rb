require_relative 'classmethods'

class Striuct; module Containable

  class << self
    
    private

    def included(klass)
      klass.extend ClassMethods
    end
    
  end

end; end
