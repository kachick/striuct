class Striuct; module Containable

  class SpecificContainer

    attr_reader :value

    def initialize(value)
      @value = value
    end

  end
  
  if respond_to? :private_constant
    private_constant :SpecificContainer
  end

end; end
