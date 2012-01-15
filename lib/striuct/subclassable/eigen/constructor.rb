class Striuct; module Subclassable; module Eigen
  # @group Constructor
  
  # @return [Subclass]
  def load_values(*values)
    new_instance(*values)
  end

  alias_method :new, :load_values

  # @param [#each_pair, #keys] pairs ex: Hash, Struct
  # @return [Subclass]
  def load_pairs(pairs)
    unless pairs.respond_to?(:each_pair) and pairs.respond_to?(:keys)
      raise TypeError, 'no pairs object'
    end

    raise ArgumentError, "different members" unless (pairs.keys - keys).empty?

    new.tap {|instance|
      pairs.each_pair do |name, value|
        instance[name] = value
      end
    }
  end

  alias_method :[], :load_pairs

  # @yieldparam [Subclass] instance
  # @yieldreturn [Subclass] instance
  # @return [void]
  # usuful wrapper for #new
  def define(check_assign=true, lock=true)
    raise ArgumentError, 'must with block' unless block_given?
    
    new.tap {|instance|
      yield instance
  
      if check_assign && each_member.any?{|name|! instance.assign?(name)}
        raise "not yet finished"
      end

      instance.freeze if lock
    }
  end

  # @endgroup
end; end; end