class Striuct; module Subclass

# @author Kenichi Kamiya
module Eigen

  class << self
    private
    
    def extended(klass)
      klass.class_eval do
        @names, @conditions, @flavors, @defaults = [], {}, {}, {}
        @protect_level = :prevent
      end
    end
  end
  
  # @return [Subclass]
  def new(*values)
    new_instance(*values)
  end

  # @param [#each_pair] pairs ex: Hash
  # @return [Subclass]
  def load_pairs(pairs)
    raise TypeError, 'no pairs object' unless pairs.respond_to? :each_pair

    new.tap do |r|
      pairs.each_pair do |name, value|
        if member? name
          r[name] = value
        else
          raise ArgumentError, " #{name} is not our member"
        end
      end
    end
  end
  
  # @yieldparam [Subclass] instance
  # @yieldreturn [Subclass] instance
  # @return [void]
  def define(lock=true)
    raise ArgumentError, 'must with block' unless block_given?
    
    new.tap do |instance|
      yield instance
  
      if each_member.all?{|name|instance.assign? name}
        instance.freeze if lock
      else
        raise "not yet finished"
      end
    end
  end

  # @return [Array<Symbol>]
  def names
    @names.dup
  end

  alias_method :members, :names
  alias_method :keys, :names

  def has_member?(name)
    @names.include? convert_cname(name)
  end
  
  alias_method :member?, :has_member?
  alias_method :has_key?, :has_member?
  alias_method :key?, :has_key?

  def has_conditions?(name)
    raise NameError unless member? name

    ! @conditions[name].nil?
  end
  
  alias_method :restrict?, :has_conditions?

  # @param [Symbol, String] name
  # @param [Object] value
  # @param [Object] context - expected own instance
  def sufficent?(name, value, context=self)
    name = convert_cname name
    raise NameError unless member? name

    if restrict? name
      conditions_for(name).any?{|condition|
        case condition
        when Proc
          context.instance_exec value, &condition
        when Method
          condition.call value
        else
          condition === value
        end
      }
    else
      true
    end
  end
  
  alias_method :accept?, :sufficent?

  # @param [Symbol, String] name
  def has_flavor?(name)
    name = convert_cname name
    raise NameError unless member? name

    ! @flavors[name].nil?
  end

  # @param [Symbol, String] name
  def has_default?(name)
    name = convert_cname name
    raise NameError unless member? name

    @defaults.has_key? name
  end
  
  # @yield [name] 
  # @yieldparam [Symbol] name - sequential under defined
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_name(&block)
    return to_enum(__method__) unless block_given?
    @names.each(&block)
    self
  end
  
  alias_method :each_member, :each_name
  alias_method :each_key, :each_name

  # @return [Integer]
  def length
    @names.length
  end
  
  alias_method :size, :length

  # @param [Object] name
  def cname?(name)
    convert_cname name
  rescue Exception
    false
  else
    true
  end

  # @param [Object] condition
  def conditionable?(condition)
    case condition
    when Proc, Method
      condition.arity == 1
    else
      condition.respond_to? :===
    end
  end
  
  def closed?
    __stores__.any?(&:frozen?)
  end

  # @return [self]
  def freeze
    __stores__.each(&:freeze)
    super
  end
  
  private

  def __stores__
    [@names, @conditions, @flavors, @defaults]
  end
  
  def initialize_copy(org)
    @names, @conditions, @flavors, @defaults = *__stores__.map(&:dup)
    @protect_level = @protect_level
  end
  
  # @return [self]
  def close
    __stores__.each(&:freeze)
    self
  end

  # @param [Symbol, String] name
  # @return [Symbol]
  def convert_cname(name)
    case name
    when Symbol, String
      r = name.to_sym

      if r.instance_of? Symbol
        r
      else
        raise 'must not happen'
      end
    else
      raise TypeError
    end
  end

  # @param [Symbol] name
  # @return [Symbol]
  def estimate_naming(name)
    if (instance_methods + private_instance_methods).include? name
      return :conflict
    end

    return :no_ascii unless name.encoding.equal? Encoding::ASCII

    case name
    when /[\W]/, /\A[^a-zA-Z_]/, :''
      :no_identifier
    when /\Aeach/, /\A__\w*__\z/, /[!?]\z/
      :bad_manners
    when /\A[a-zA-Z_]\w*\z/
      :strict
    else
      raise 'must not happen'
    end
  end

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
  
  if respond_to? :private_constant
    private_constant :PROTECT_LEVELS, :NAMING_RISKS
  end

  # @param [Symbol] name
  def check_safety_naming(name)
    estimation = estimate_naming name
    risk    = NAMING_RISKS[estimation]
    plevels = PROTECT_LEVELS[@protect_level]
    caution = "undesirable naming '#{name}', because #{estimation}"

    case
    when risk >= plevels[:error]
      raise NameError, caution
    when risk >= plevels[:warn]
      warn caution
    end
  end

  # @macro [attach] protect_level
  # @param [Symbol] level
  def protect_level(level)
    raise NameError unless PROTECT_LEVELS.has_key? level
    
    @protect_level = level
    nil
  end

  # @macro [attach] member
  # @return [nil]
  def define_member(name, *conditions, &flavor) 
    raise "already closed to add member in #{self}" if closed?
    name = convert_cname name
    raise ArgumentError, %Q!already exist name "#{name}"! if member? name
    check_safety_naming name

    @names << name
    __getter__! name
    __setter__! name, *conditions, &flavor
    nil
  end

  alias_method :def_member, :define_member
  alias_method :member, :define_member

  # @macro [attach] define_members
  # @return [nil]
  def define_members(*names)
    raise "already closed to add members in #{self}" if closed?
    unless names.length >= 1
      raise ArgumentError, 'wrong number of arguments (0 for 1+)'
    end
    
    names.each do |name|
      define_member name
    end

    nil
  end

  alias_method :def_members, :define_members

  def __getter__!(name)
    name = convert_cname name
    
    define_method name do
      __get__ name
    end
    
    nil
  end

  def __setter__!(name, *conditions, &flavor)
    name = convert_cname name
    
    __set_conditions__! name, *conditions
    __set_flavor__! name, &flavor if block_given?

    define_method "#{name}=" do |value|
      __set__ name, value
    end
 
    nil
  end
  
  def __set_conditions__!(name, *conditions)
    unless conditions.empty?
      if conditions.all?{|c|conditionable? c}
        @conditions[name] = conditions
      else
        raise TypeError, 'wrong object for condition'
      end
    end
 
    nil
  end

  def __set_flavor__!(name, &flavor)
    if flavor.arity == 1
      @flavors[name] = flavor
    else
      raise ArgumentError, "wrong number of block argument #{flavor.arity} for 1"
    end
 
    nil
  end

  def get_conditions(name)
    name = convert_cname name
    raise NameError, 'no defined member' unless member? name

    @conditions[name]
  end
  
  alias_method :conditions_for, :get_conditions

  def get_flavor(name)
    name = convert_cname name
    raise NameError, 'no defined member' unless member? name

    @flavors[name]
  end
  
  alias_method :flavor_for, :get_flavor

  # @param [Symbol, String] name
  def get_default_value(name)
    name = convert_cname name
    raise NameError, 'no defined member' unless member? name
  
    @defaults[name]
  end

  alias_method :default_for, :get_default_value
  public :default_for

  # @macro [attach] default
  # @return [nil]
  def set_default_value(name, value)
    raise "already closed to modify member attributes in #{self}" if closed?
    name = convert_cname name
    raise NameError, 'no defined member' unless member? name
    raise ConditionError unless accept? name, value 
  
    @defaults[name] = value
    nil
  end
  
  alias_method :default, :set_default_value


end


end; end
