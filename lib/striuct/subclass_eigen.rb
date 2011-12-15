class Striuct; module Subclass

# @author Kenichi Kamiya
module Eigen

  class << self
    private
    
    def extended(mod)
      mod.module_eval do
        @members = []
        @conditions = {}
      end
    end
  end
  
  def initialize_copy(org)
    @members = @members.clone
    @conditions = @members.clone
  end

  # @return [instance]
  def new(*values)
    new_instance(*values)
  end

  # @return [instance]
  def load_pairs(pairs)
    raise TypeError, 'no pairs object' unless pairs.respond_to? :each_pair

    new.tap do |r|
      pairs.each_pair do |key, value|
        if member? key
          r[key] = value
        else
          raise ArgumentError, " #{key} is not our member"
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

  # @return [Hash<Symbol=>Array>]
  def conditions
    @conditions.dup
  end
  
  def restrict?(name)
    raise NameError unless member? name

    !@conditions[name].nil?
  end
  
  alias_method :keys, :members
  
  def has_member?(key)
    if key.instance_of? Symbol
      @members.include? key
    else
      raise TypeError
    end
  end
  
  alias_method :member?, :has_member?
  alias_method :has_key?, :has_member?
  alias_method :key?, :has_key?
  
  def sufficent?(name, value)
    raise NameError unless member? name

    if conditions = @conditions[name]
      conditions.any?{|condition|condition === value}
    else
      true
    end
  end
  
  alias_method :accept?, :sufficent?

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
  
  private

  # @macro define_member
  # @return [nil]
  def define_member(name, *conditions, &block)   
    case name
    when Symbol
    when String
      name = name.to_sym
    else
      raise TypeError
    end

    unless member? name
      @members << name
      define_reader name
      define_writer(name, *conditions, &block)
    else
      raise ArgumentError, %Q!already exsist name "#{name}"!
    end
    
    nil
  end

  alias_method :def_member, :define_member
  alias_method :member, :define_member

  # @macro define_members
  # @return [nil]
  def define_members(*names)
    raise ArgumentError, 'wrong number of arguments (0 for 1+)' unless names.length >= 1
    
    names.each do |name|
      define_member name
    end

    nil
  end

  alias_method :def_members, :define_members

  # @macro define_pairs
  # @return [nil]
  def define_pairs(pairs)
    raise TypeError, 'no pairs object' unless pairs.respond_to? :each_pair

    pairs.each_pair do |k, v|
      define_member k, v
    end
    
    nil
  end
  
  alias_method :def_pairs, :define_pairs

  # @macro define_reader
  # @return [nil]
  def define_reader(key)
    raise TypeError unless key.instance_of? Symbol
    
    define_method key do
      __get__ key
    end
    
    nil
  end

  # @macro define_writer
  # @return [nil]
  # @raise [ConditionError] argument unmatch all conditions or block
  def define_writer(name, *conditions, &block)
    raise TypeError unless name.instance_of? Symbol
  
    if conditions.empty?
      if block_given?
        define_writer_under_blockcondition name, &block
      else
        define_writer_through name
      end
    else
      if block_given?
        raise ArgumentError, 'unavailable arguments and block'
      else
        define_writer_under_conditions(name, *conditions)
      end
    end
    
    nil
  end
  
  def define_writer_through(name)
    define_method "#{name}=" do |value|
      __set__ name, value
    end
  end
  
  def define_writer_under_blockcondition(name, &block)
    @conditions[name] = [ block ]
    define_writer_through name
  end
  
  def define_writer_under_conditions(name, *conditions)
    @conditions[name] = conditions
    define_writer_through name
  end

end


end; end
