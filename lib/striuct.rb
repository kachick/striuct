# frozen_string_literal: true

# striuct - Struct++
# Copyright (c) 2011-2012 Kenichi Kamiya

# @abstract
class Striuct
  class Error < StandardError; end
  class InvalidOperationError < Error; end
  class InvalidValueError < Error; end
  class InvalidWritingError < InvalidValueError; end
  class InvalidReadingError < InvalidValueError; end
  class InvalidAdjustingError < InvalidValueError; end
end

require_relative 'striuct/bootstrap'
