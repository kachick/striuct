# striuct - Provides a Struct++ class.
# Copyright (c) 2011 Kenichi Kamiya

require 'validation'

# @abstract
class Striuct

  include Validation

  # namespace for .to_struct_class, #to_struct
  module Structs
  end

end

require_relative 'striuct/version'
require_relative 'striuct/specificcontainer'
require_relative 'striuct/classmethods'
require_relative 'striuct/instancemethods'
require_relative 'striuct/singleton_class'