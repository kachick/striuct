require_relative 'named'
require_relative 'enum'

class Striuct; module ClassMethods

  # @group Like Ruby's Hash

  alias_method :keys, :autonyms
  alias_method :has_key?, :has_member?
  alias_method :key?, :has_key?
  alias_method :each_key, :each_autonym

  # @endgroup


  # @group Like Ruby's Hash +

  alias_method :each_key_with_index, :each_autonym_with_index

  # @endgroup

end; end
