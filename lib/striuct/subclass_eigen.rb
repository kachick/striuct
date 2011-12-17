class Striuct; module Subclass

# @author Kenichi Kamiya
module Eigen

  class << self
    private
    
    def extended(klass)
      klass.class_eval do
        @members, @conditions, @procedures, @defaults = [], {}, {}, {}
      end
    end
  end
  
  def initialize_copy(org)
    instance_variables.each do |var|
      instance_variable_set var, instance_variable_get(var).clone
    end
  end

  # @return [instance]
  def new(*values)
    new_instance(*values)
  end

  # @return [instance]
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
  
  # @return [instance]
  # @yieldparam [instance]
  def define(lock=true)
    new.tap do |instance|
      yield instance
      instance.lock if lock
    end
  end

  # @return [Array<Symbol>]
  def members
    @members.dup
  end

  alias_method :keys, :members

  # @return [Hash<Symbol=>Array>]
  def conditions
    @conditions.dup
  end

  # @return [Hash<Symbol=>Proc>]
  def procedures
    @procedures.dup
  end
  
  # @return [Hash<Symbol=>Object>]
  def defaults
    @defaults.dup
  end

  def has_member?(name)
    @members.include? convert_cname(name)
  end
  
  alias_method :member?, :has_member?
  alias_method :has_key?, :has_member?
  alias_method :key?, :has_key?

  def has_condition?(name)
    raise NameError unless member? name

    !@conditions[name].nil?
  end
  
  alias_method :restrict?, :has_condition?

  def sufficent?(name, value)
    name = convert_cname name
    raise NameError unless member? name

    if conditions = @conditions[name]
      conditions.any?{|c|c === value}
    else
      true
    end
  end
  
  alias_method :accept?, :sufficent?
  
  def has_default?(name)
    raise NameError unless member? name

    @defaults.has_key? name
  end

  # @return [self]
  def each_member(&block)
    return to_enum(__method__) unless block_given?
    @members.each(&block)
    self
  end
  
  alias_method :each_key, :each_member

  # @return [Integer]
  def length
    @members.length
  end
  
  alias_method :size, :length
  
  def cname?(name)
    convert_cname name
  rescue Exception
    false
  else
    true
  end

  def conditionable?(condition)
    if condition.respond_to? :===
      case condition
      when Proc, Method
        condition.arity == 1
      else
        true
      end
    else
      false
    end
  end
  
  private
  
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

  # @macro [attach] member
  # @return [nil]
  def define_member(name, *conditions, &block)   
    name = convert_cname name
    raise ArgumentError, %Q!already exsist name "#{name}"! if member? name

    @members << name
    define_reader name
    define_writer(name, *conditions, &block)
    nil
  end

  alias_method :def_member, :define_member
  alias_method :member, :define_member

  # @macro [attach] define_members
  # @return [nil]
  def define_members(*names)
    raise ArgumentError, 'wrong number of arguments (0 for 1+)' unless names.length >= 1
    
    names.each do |name|
      define_member name
    end

    nil
  end

  alias_method :def_members, :define_members

  def define_reader(name)
    name = convert_cname name
    
    define_method name do
      __get__ name
    end
    
    nil
  end

  def define_writer(name, *conditions, &procedure)
    name = convert_cname name
    
    unless conditions.empty?
      if conditions.all?{|c|conditionable? c}
        @conditions[name] = conditions
      else
        raise ArgumentError, 'wrong object for condition'
      end
    end

    if block_given?
      if procedure.arity == 1
        @procedures[name] = procedure
      else
        raise ArgumentError, "wrong number of block argument #{procedure.arity} for 1"
      end
    end

    define_method "#{name}=" do |value|
      __set__ name, value
    end
 
    nil
  end
  
  # @macro [attach] default
  # @return [nil]
  def define_default_value(name, value)
    name = convert_cname name
    raise NameError, 'before define member' unless member? name
    raise ConditionError unless accept? name, value 
  
    @defaults[name] = value
    nil
  end
  
  alias_method :default, :define_default_value
  
end


end; end
