# frozen_string_literal: true

class Striuct
  module InstanceMethods
    # @group Delegate Class Methods

    def_delegators :'self.class',
                   :autonym_for_alias,
                   :autonym_for_member,
                   :autonym_for_index,
                   :autonym_for_key,
                   :autonyms, :members, :all_members, :aliases, :attributes,
                   :has_autonym?, :autonym?,
                   :has_alias?, :alias?, :aliased?,
                   :has_member?, :member?,
                   :has_index?, :index?,
                   :has_key?, :key?,
                   :with_aliases?,
                   :aliases_for_autonym,
                   :length, :size,
                   :with_condition?, :restrict?,
                   :condition_for,
                   :with_safety_getter?, :with_safety_reader?,
                   :with_safety_setter?, :with_safety_writer?,
                   :with_must?, :must?,
                   :with_default?,
                   :default_value_for, :default_type_for,
                   :with_adjuster?,
                   :adjuster_for

    private

    def _autonyms
      self.class.__send__(:_autonyms)
    end

    # @endgroup
  end
end
