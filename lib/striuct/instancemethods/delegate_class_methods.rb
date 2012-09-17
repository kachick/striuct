require 'forwardable'

class Striuct; module InstanceMethods
  
  extend Forwardable
  
  # Forwardable has public/protected class_macro
  private_class_method(*Forwardable.instance_methods)

  # @group Delegate Class Methods
  
  def_delegators :'self.class',
    :_autonyms, :_nameable_for,
    :autonym_for, :autonym_for_name, :autonym_for_key,
    :aliases_for,
    :validator_for, :condition_for,
    :adjuster_for, :flavor_for,
    :members, :keys, :autonyms, :all_members, :aliases,
    :has_member?, :member?, :has_key?, :key?,
    :has_autonym?, :autonym?,
    :has_alias?, :alias?, :aliased?,
    :has_aliases?,
    :length, :size,
    :restrict?, :has_validator?, :has_condition?,
    :safety_getter?, :safety_reader?, :safety_setter?, :safty_writer?,
    :inference?,
    :has_default?, :default_value_for, :default_for, :default_type_for,
    :has_adjuster?, :has_flavor?

  private :_autonyms, :_nameable_for

  # @endgroup
  
end; end
