autoload :YAML, 'yaml'

class Striuct; module Containable
  # @group for YAML

  # @return [String]
  def to_yaml
    YAML.__id__   # for autoload
    klass = Struct.new(*members)
    klass.new(*values).to_yaml
  end
  
  # @endgroup
end; end