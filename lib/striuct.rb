# frozen_string_literal: true

# striuct - Struct++
# Copyright (c) 2011-2012 Kenichi Kamiya

# @abstract
class Striuct
  class Error < StandardError; end
  class InvalidOperationError < Error; end
end

require_relative 'striuct/requirements'
