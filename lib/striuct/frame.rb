# @author Kenichi Kamiya
# @abstract
class Striuct
  class ConditionError < ArgumentError; end
  
  # only namespace for .to_struct_class, #to_struct
  module Structs
  end
end

require_relative 'version'
require_relative 'abstract'