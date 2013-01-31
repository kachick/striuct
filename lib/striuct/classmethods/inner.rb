class Striuct; module ClassMethods

  # @group Inner Methods

  private

  def _init
    @autonyms      = []
    @attributes    = {}.extend HashDeepDupulicatable # autonym => Attributes
    @aliases       = {} # aliased => autonym
    @conflict_management_level = DEFAULT_CONFLICT_MANAGEMENT_LEVEL
  end

  def _add_autonym(autonym)
    autonym = autonym.to_sym
    raise NameError, 'already defined' if member? autonym

    @attributes[autonym] = Attributes.new
    @autonyms << autonym
  end

  def _attributes_for(autonym)
    @attributes.fetch autonym
  end

  def _def_getter(autonym) 
    define_method autonym do
      _get autonym
    end
    
    nil
  end

  def _def_setter(autonym, condition, &adjuster)
    unless ANYTHING.equal? condition
      _attributes_for(autonym).condition = condition
    end

    if block_given?
      _attributes_for(autonym).adjuster = adjuster
    end

    define_method :"#{autonym}=" do |value|
      _set autonym, value
    end
 
    nil
  end

  def _found_family(autonym, other)
    family = other.class

    _attributes_for(autonym).condition = family
    _attributes_for(autonym).inference = false

    nil
  end
  
  # @endgroup

end; end