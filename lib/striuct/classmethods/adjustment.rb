class Striuct; module ClassMethods

  # @group Adjuster
  
  # @param [Symbol, String] name
  def has_adjuster?(name)
    name = autonym_for name

    ! flavor_for(name).nil?
  end

  alias_method :has_flavor?, :has_adjuster?
  
  # @param [Symbol, String] name
  def adjuster_for(name)
    _flavor_for autonym_for(name)
  end
  
  alias_method :flavor_for, :adjuster_for

  private
  
  def _adjuster_for(name)
    @flavors[name]
  end
  alias_method :_flavor_for, :_adjuster_for

  # @endgroup

end; end