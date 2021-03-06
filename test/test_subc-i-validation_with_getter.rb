# frozen_string_literal: false
require_relative 'helper'

class Test_Striuct_Subclass_Instance_GetterValidation < Test::Unit::TestCase

  Sth = Striuct.define do
    member :plus_getter, /./, reader_validation: true
    member :only_getter, /./, reader_validation: true, writer_validation: false
  end

  def test_reader_validation
    sth = Sth.new

    assert_raises Striuct::InvalidWritingError do
      sth.plus_getter = ''
    end

    sth.plus_getter = 'abc'
    assert_equal 'abc', sth.plus_getter
    sth.plus_getter.clear

    assert_raises Striuct::InvalidReadingError do
      sth.plus_getter
    end

    sth.only_getter = ''

    assert_raises Striuct::InvalidReadingError do
      sth.only_getter
    end
  end

end
