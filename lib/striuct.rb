# Copyright (C) 2011  Kenichi Kamiya
# Striuct
#   Provides a Struct++ class.

require 'validation'

# @author Kenichi Kamiya
# @abstract
class Striuct
  include Validation

  # namespace for .to_struct_class, #to_struct
  module Structs
  end
end

require_relative 'striuct/version'
require_relative 'striuct/abstract'