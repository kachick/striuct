class Striuct; module InstanceMethods

  # @group To Strings
  
  # @return [String]
  def inspect
    "#<struct' #{self.class} strict?:#{strict?}".tap {|s|
      each_pair do |autonym, value|
        suffix = (with_default?(autonym) && default?(autonym)) ? '/default' : nil
        s << " #{autonym}=#{value.inspect}#{suffix}("
        s << "valid?:#{valid? autonym}, "
        s << "locked?:#{locked? autonym}"
        s << '),'
      end
      
      s.chop!
      s << '>'
    }
  end

  # @return [String]
  def to_s
    "#<struct' #{self.class}".tap {|s|
      each_pair do |autonym, value|
        s << " #{autonym}=#{value.inspect},"
      end
      
      s.chop!
      s << '>'
    }
  end

  # @endgroup

end; end
