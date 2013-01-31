class Striuct; module InstanceMethods

  # @group Basic Methods for Ruby's Object
  
  def initialize(*values)
    @db, @locks = {}, {}
    replace_values(*values)
    excess_autonyms = _autonyms.last(size - values.size)
    _set_defaults(*excess_autonyms)
  end

  # @return [self]
  def freeze
    @db.freeze; @locks.freeze
    super
  end
  
  private
  
  def initialize_copy(original)
    @db, @locks = @db.dup, {}
  end

  # @endgroup

end; end