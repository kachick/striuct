class Striuct; module ClassMethods

  # @group Fix inner data structures 

  # @return [self]
  def freeze
    [@autonyms, @attributes, @aliases].each(&:freeze)
    super
  end

  def closed?
    [@autonyms, @attributes, @aliases].any?(&:frozen?)
  end

  private

  # @return [self]
  def close_member
    [@autonyms, @attributes, @aliases].each(&:freeze)
    self
  end
  
  alias_method :fix_structural, :close_member
  alias_method :close, :close_member

  # @endgroup

end; end
