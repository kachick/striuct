require_relative 'helper'

class Test_Striuct_Subclass_Instance_Default_Value < Test::Unit::TestCase

  Sth = Striuct.new do
    member :lank, OR(Bignum, Fixnum)
    default :lank, 1
  end
  
  def test_default
    sth = Sth.new 2
    assert_equal 2, sth.lank
    sth = Sth.new
    assert_equal 1, sth.lank
    assert_equal true, sth.default?(:lank)
    sth.lank = 2
    assert_equal false, sth.default?(:lank)
  end
  
  def test_define_default
    assert_raises NameError do
      Sth.class_eval do
        default :anything, 10
      end
    end
    
    klass = Striuct.define do
      member :lank2, Integer
      default :lank2, '10'
    end

    assert_raises Validation::InvalidWritingError do
      klass.new
    end
    
    scope = self
    seef = nil
    klass = Striuct.define do
      member :lank, Integer

      scope.assert_raises ArgumentError do
        default :lank, &->own, name, exess{rand}
      end

      scope.assert_raises ArgumentError do
        default :lank, '10', &->own, name{rand}
      end
      
      scope.assert_raises ArgumentError do
        default :lank, '10', &->own{rand}
      end
      
      scope.assert_raises ArgumentError do
        default :lank, '10', &->{rand}
      end
      
      default :lank, &->own, name{(seef = own); rand}
    end
    
    assert_raises Validation::InvalidWritingError do
      klass.new
    end
    
    klass = Striuct.define do
      member :lank, Integer      
      default :lank, &->own, name{(seef = own); 10 - name.length}
    end
    
    assert_equal 6, klass.new.lank
    assert_equal seef, klass.new
  end

end

class Test_Striuct_Subclass_Instance_DefaultValue_Under_MemberMacro < Test::Unit::TestCase

  Sth = Striuct.new do
    member :lank, OR(Bignum, Fixnum), default: 1
  end
  
  def test_default
    sth = Sth.new 2
    assert_equal 2, sth.lank
    sth = Sth.new
    assert_equal 1, sth.lank
    assert_equal true, sth.default?(:lank)
    sth.lank = 2
    assert_equal false, sth.default?(:lank)
  end
  
  def test_define_default
    assert_raises NameError do
      Sth.class_eval do
        default :anything, 10
      end
    end
    
    klass = Striuct.define do
      member :lank2, Integer, default: '10'
    end

    assert_raises Validation::InvalidWritingError do
      klass.new
    end
    
    scope = self
    seef = nil
    klass = Striuct.define do
      
      scope.assert_raises ArgumentError do
        member :lank, Integer, default: '10', default_proc: ->own,name{rand}
      end
      
      member :lank, Integer, default_proc: ->own,name{(seef = own); rand}
    end
    
    assert_raises Validation::InvalidWritingError do
      klass.new
    end
    
    klass = Striuct.define do
      member :lank, Integer, default_proc: ->own,name{(seef = own); 10 - name.length}
    end
    
    assert_equal 6, klass.new.lank
    assert_equal seef, klass.new
  end

end