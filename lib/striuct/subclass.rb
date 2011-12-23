require_relative 'classutil'

class Striuct


# @author Kenichi Kamiya
module Subclass

  extend ClassUtil
  include Enumerable
  
  def initialize(*values)
    @db = {}
    
    if values.size <= size
      values.each_with_index do |v, idx|
        self[idx] = v
      end
      
      excess = members.last(size - values.size)
      
      excess.each do |name|
        self[name] = default_for name if has_default? name
      end
    else
      raise ArgumentError, "struct size differs (max: #{size})"
    end
  end
  
  # @return [Boolean]
  def ==(other)
    if self.class.equal? other.class
      each_pair.all?{|k, v|v == other[k]}
    else
      false
    end
  end
  
  def eql?(other)
    if self.class.equal? other.class
      each_pair.all?{|k, v|v.eql? other[k]}
    else
      false
    end
  end
  
  # @return [Integer]
  def hash
    values.map(&:hash).hash
  end
  
  # @return [String]
  def inspect
    "#<#{self.class} (StrictStruct)".tap do |s|
      each_pair do |name, value|
        suffix = (has_default?(name) && default?(name)) ? '(default)' : nil
        s << " #{name}=#{value.inspect}#{suffix}"
      end
      
      s << ">"
    end
  end

  # @return [String]
  def to_s
    "#<struct #{self.class}".tap do |s|
      each_pair do |name, value|
        s << " #{name}=#{value.inspect}"
      end
      
      s << '>'
    end
  end

  delegate_class_methods(
    :members, :keys, :has_member?, :member?, :has_key?, :key?, :length,
    :size, :keyable_for, :restrict?, :has_default?, :default_for,
    :names, :has_flavor?, :flavor_for, :has_conditions?, :inference?
  )
  
  private :keyable_for, :flavor_for
  
  # @param [Symbol, String, Fixnum] key
  def [](key)
    __subscript__(key){|name|__get__ name}
  end
  
  # @param [Symbol, String, Fixnum] key
  # @param [Object] value
  def []=(key, value)
    __subscript__(key){|name|__set__ name, value}
  end

  # @yield [name] 
  # @yieldparam [Symbol] name - sequential under defined
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_name
    return to_enum(__method__) unless block_given?
    self.class.each_name{|name|yield name}
    self
  end

  alias_method :each_member, :each_name
  alias_method :each_key, :each_name

  # @yield [value]
  # @yieldparam [Object] value - sequential under defined (see #each_name)
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_value
    return to_enum(__method__) unless block_given?
    each_member{|member|yield self[member]}
  end
  
  alias_method :each, :each_value

  # @yield [name, value]
  # @yieldparam [Symbol] name (see #each_name)
  # @yieldparam [Object] value (see #each_value)
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_pair
    return to_enum(__method__) unless block_given?
    each_name{|name|yield name, self[name]}
  end

  # @return [Array]
  def values
    [].tap do |r|
      each_value do |v|
        r << v
      end
    end
  end
  
  alias_method :to_a, :values

  # @param [Fixnum, Range] *keys
  # @return [Array]
  def values_at(*keys)
    [].tap do |r|
      keys.each do |key|
        case key
        when Fixnum
          r << self[key]
        when Range
          key.each do |n|
            r << self[n]
          end
        else
          raise TypeError
        end
      end
    end
  end

  # @param [Symbol, String] name
  def assign?(name)
    name = keyable_for name
    raise NameError unless member? name
    
    @db.has_key? name
  end

  # @param [Symbol, String] name
  def unassign(name)
    raise "can't modify frozen #{self.class}" if frozen?
    name = keyable_for name
    raise NameError unless member? name
    
    @db.delete name
  end
  
  # @param [Symbol, String] name
  # @param [Object] *values - no argument and use own
  def sufficent?(name, value=self[name])
    self.class.__send__(__method__, name, value, self)
  end
  
  alias_method :accept?, :sufficent?

  def strict?
    each_pair.all?{|name, value|self.class.sufficent? name, value}
  end
  
  def secure?
    frozen? && self.class.closed? && strict?
  end
  
  # @return [self]
  def freeze
    @db.freeze
    super
  end
  
  # @param [Symbol, String] name
  def default?(name)
    default_for(name) == self[name]
  end

  private
  
  def initialize_copy(org)
    @db = @db.clone
  end

  def __get__(name)
    name = keyable_for name
    raise NameError unless member? name

    @db[name]
  end

  def __set__(name, value)
    raise "can't modify frozen #{self.class}" if frozen?
    name = keyable_for name
    raise NameError unless member? name

    if accept? name, value
      if has_flavor? name
        value = instance_exec value, &flavor_for(name)
      end

      if inference? name
        self.class.__send__ :__found_family__!, name, value
      end
      
      @db[name] = value
    else
      raise ConditionError, 'deficent value for all conditions'
    end
  end
  
  alias_method :assign, :__set__
  public :assign
  
  def __subscript__(key)
    case key
    when Symbol, String
      name = keyable_for key
      if member? name
        yield name
      else
        raise NameError
      end
    when Fixnum
      if name = members[key]
        yield name
      else
        raise IndexError
      end
    else
      raise ArgumentError
    end
  end


end


end
