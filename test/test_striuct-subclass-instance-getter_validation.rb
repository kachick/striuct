require_relative 'helper'

class TestGetterValidation < Test::Unit::TestCase

  Sth = Striuct.define do
    member :plus_getter, /./, getter_validation: true
    member :only_getter, /./, getter_validation: true,
                              setter_validation: false
  end
  
  def test_getter_validation
    sth = Sth.new
    
    assert_raises Validation::InvalidWritingError do
      sth.plus_getter = ''
    end
    
    sth.plus_getter = 'abc'
    assert_equal 'abc', sth.plus_getter
    sth.plus_getter.clear
    
    assert_raises Validation::InvalidReadingError do
      sth.plus_getter
    end
    
    sth.only_getter = ''
    
    assert_raises Validation::InvalidReadingError do
      sth.only_getter
    end
  end

end
