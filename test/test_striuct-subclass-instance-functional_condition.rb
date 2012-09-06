require_relative 'helper'

class TestStriuctFunctionalCondition < Test::Unit::TestCase

  Sthlambda = Striuct.new do
    member :lank, ->lank{lanks.include? lank}
    member :lanks
    default :lanks, 1..30
  end
  
  def test_lambda
    sth = Sthlambda.new
    sth.lank = 2
    assert_equal 2, sth.lank
    
    assert_raises Validation::InvalidWritingError do
      sth.lank = 31
    end
  end
  
  max = 9

  SthProc = Striuct.new do
    member :lank, Proc.new{|n|(3..max) === n}
  end

  def test_Proc
    sth = SthProc.new
    sth.lank = 8
    assert_equal 8, sth.lank
    
    assert_raises Validation::InvalidWritingError do
      sth.lank = 2
    end
  end
  
  SthMethod = Striuct.new do
    member :lank, 7.method(:<)
  end
  
  def test_Method
    sth = SthMethod.new
    sth.lank = 8
    assert_equal 8, sth.lank
    
    assert_raises Validation::InvalidWritingError do
      sth.lank = 6
    end
  end

end