class Striuct; module InstanceMethods

  # @group Delegate Class Methods
  
  # @see self.class.*args
  delegate_class_methods(
    :keyable_for, :autonym_for,
    :validator_for, :condition_for,
    :adjuster_for, :flavor_for,
    :members, :keys, :names, :autonyms, :all_members, :aliases,
    :has_member?, :member?, :has_key?, :key?,
    :length, :size,
    :restrict?, :has_validator?, :has_condition?,
    :safety_getter?, :safety_reader?, :safety_setter?, :safty_writer?, :inference?,
    :has_default?, :default_for, :has_flavor?
  )

  # @endgroup

end; end
