class Striuct; module InstanceMethods

  # @group Basic Methods for Ruby's Object
  
  def initialize(*values)
    @db, @locks = {}, {}
    replace_values(*values)
    excess = _autonyms.last(size - values.size)
    set_defaults(*excess)
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

  # @group Default Value

  # @return [self]
  def set_defaults(*target_autonyms)
    target_autonyms.each do |autonym|
      if has_default? autonym
        default = default_value_for autonym
        self[autonym] = (
          if default_type_for(autonym) == :lazy
            args = [self, autonym][0, default.arity]
            default.call(*args)
          else
            default
          end
        )
      end
    end
    
    self
  end

  # @endgroup

end; end
