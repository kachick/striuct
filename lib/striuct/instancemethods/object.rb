class Striuct; module InstanceMethods

  # @group Basic Methods for Ruby's Object
  
  def initialize(*values)
    @db, @locks = {}, {}
    replace_values(*values)
  end
  
  # @return [String]
  def inspect
    "#<#{self.class} (Striuct)".tap {|s|
      each_pair do |autonym, value|
        suffix = (has_default?(autonym) && default?(autonym)) ? '(default)' : nil
        s << " #{autonym}=#{value.inspect}#{suffix}"
      end
      
      s << ">"
    }
  end

  # @return [String]
  def to_s
    "#<struct #{self.class}".tap {|s|
      each_pair do |autonym, value|
        s << " #{autonym}=#{value.inspect}"
      end
      
      s << '>'
    }
  end

  # @return [self]
  def freeze
    [@db, @locks].each(&:freeze)
    super
  end
  
  private
  
  def initialize_copy(original)
    @db, @locks = @db.dup, {}
  end

  # @endgroup

end; end
