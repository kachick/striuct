class Striuct

  class SpecificContainer

    attr_reader :value

    def initialize(value)
      @value = value
    end

  end
  
  class DefaultProcHolder < SpecificContainer; end

  if respond_to? :private_constant
    private_constant :SpecificContainer, :DefaultProcHolder
  end

end
