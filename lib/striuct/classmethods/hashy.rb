require_relative 'named'
require_relative 'enum'

class Striuct; module ClassMethods

  # @group Like Ruby's Hash

  alias_method :has_key?, :has_member?
  alias_method :key?, :has_key?

  # @endgroup

end; end
