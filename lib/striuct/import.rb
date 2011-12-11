class Striuct
  module StructExtension
    def strict?
      false
    end
  end
end

class Struct
  include Striuct::StructExtension
end