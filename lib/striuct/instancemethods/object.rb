class Striuct; module InstanceMethods

  # @group Basic Methods for Ruby's Object
  
  def initialize(*values)
    @db, @locks = {}, {}
    replace_values(*values)
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
