class Striuct; module ClassMethods
  
  # @group Prevent Naming Conflicts

  NAMING_RISKS = {
    conflict:      10,
    no_identifier:  9,
    bad_manners:    5,
    no_ascii:       3,
    strict:         0 
  }.freeze

  PROTECT_LEVELS = {
    struct:      {error: 99, warn: 99},
    warning:     {error: 99, warn:  5},
    error:       {error:  9, warn:  5},
    prevent:     {error:  5, warn:  1},
    nervous:     {error:  1, warn:  1}
  }.each(&:freeze).freeze

  # @param [Object] name
  # accpeptable the name into own member, under protect level of runtime
  def cname?(name)
    _check_safety_naming(keyable_for name){|r|r}
  rescue Exception
    false
  end

  private

  # @param [Symbol] level
  # @return [nil]
  # change protect level for risk of naming members
  def protect_level(level)
    raise NameError unless PROTECT_LEVELS.has_key? level
    
    @protect_level = level
    nil
  end
  
  # @param [Symbol] name
  # @return [void]
  # @yieldreturn [Boolean]
  def _check_safety_naming(name)
    estimation = _estimate_naming name
    risk    = NAMING_RISKS[estimation]
    plevels = PROTECT_LEVELS[@protect_level]
    caution = "undesirable naming '#{name}', because #{estimation}"

    r = (
      case
      when risk >= plevels[:error]
        raise NameError, caution unless block_given?
        false
      when risk >= plevels[:warn]
        warn caution unless block_given?
        false
      else
        true
      end
    )

    yield r if block_given?
  end
  
  # @param [Symbol] name
  # @return [Symbol]
  def _estimate_naming(name)
    if (instance_methods + private_instance_methods).include? name
      return :conflict
    end

    return :no_ascii unless name.encoding.equal? Encoding::ASCII

    case name
    when /[\W]/, /\A[^a-zA-Z_]/, :''
      :no_identifier
    when /\Aeach/, /\A__[^_]*__\z/, /\A_[^_]*\z/, /[!?]\z/, /\Ato_/
      :bad_manners
    when /\A[a-zA-Z_]\w*\z/
      :strict
    else
      raise 'must not happen'
    end
  end
  
  # @endgroup

end; end
