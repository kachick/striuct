require 'forwardable'
require 'keyvalidatable'

class Striuct; module InstanceMethods

  extend Forwardable

  # hide Forwardable's public/protected class_macro
  private_class_method(*Forwardable.instance_methods)

  include KeyValidatable

end; end

require_relative 'delegate_class_methods'
require_relative 'keyvalidatable'
require_relative 'object'
require_relative 'compare'
require_relative 'to_s'
require_relative 'values'
require_relative 'cast'
require_relative 'default'
require_relative 'enum'
require_relative 'hashy'
require_relative 'getter'
require_relative 'setter'
require_relative 'assign'
require_relative 'lock'
require_relative 'validation'
require_relative 'safety'
