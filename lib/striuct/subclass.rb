require_relative 'classutil'

class Striuct


# @author Kenichi Kamiya
module Subclass

  extend ClassUtil
  include Enumerable
  
  def initialize(*values)
    @db, @lock = {}, false
    
    if values.size <= members.size
      values.each_with_index do |v, idx|
        self[idx] = v
      end
      
      excess = members.last(members.size - values.size)
      
      excess.each do |name|
        self[name] = self.class.defaults[name] if self.class.has_default? name
      end
    else
      raise ArgumentError, "struct size differs (max: #{members.size})"
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
    "#<#{self.class} (StrictStruct)\n".tap do |s|
      members.each_with_index do |name, idx|
        s << " #{idx.to_s.rjust 3}. #{name}\n"
        s << "#{' ' * 6}assigned  : #{self[name].inspect}\n" if assign? name
        s << "#{' ' * 6}conditions: #{conditions[name].inspect}\n" if self.class.restrict? name
        s << "#{' ' * 6}procedure : #{procedures[name].inspect}\n" if procedures[name]
      end
      
      s << "\n>"
    end
  end

  # @return [String]
  def to_s
    "#<struct #{self.class}".tap do |s|
      members.each_with_index do |m, idx|
        s << " #{m}=#{self[m]}"
      end
      
      s << '>'
    end
  end

  delegate_class_methods(
    :members, :keys, :has_member?, :member?, :has_key?, :key?, :length,
    :size
  )
  
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
  # @yieldparam [Symbol] name - member's name in own class that sequential under defined
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
  # @yieldparam [Object] value - that is holded self and sequential (see #each_name)
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

  # @return [Array]
  def values_at(*names)
    [].tap do |r|
      names.each do |name|
        r << self[name]
      end
    end
  end

  # @param [Symbol, String] name
  def assign?(name)
    raise NameError unless member? name
    
    @db.has_key? name
  end

  # @param [Symbol, String] name
  # @param [Object] *values - when no argument use own holding, when one argument use it
  def sufficent?(name, *values)
    value = (
      case n = values.length
      when 0
        self[name]
      when 1
        values.first
      else
        raise ArgumentError, "wrong number of argument #{n + 1} for 1~2"
      end
    )
    
    self.class.__send__(__method__, name, value, self)
  end
  
  alias_method :accept?, :sufficent?

  def strict?
    each_pair.all?{|name, value|self.class.sufficent? name, value}
  end

  # @return [self]
  def lock
    @lock = true
    self
  end
  
  def lock?
    @lock
  end
  
  def secure?
    lock? && strict?
  end

  private
  
  def initialize_copy(org)
    @db, @lock = @db.clone, false
  end

  def __get__(name)
    raise NameError unless member? name

    @db[name]
  end

  def __set__(name, value)
    raise NameError unless member? name
    raise LockError if lock?

    if self.class.restrict? name
      if accept? name, value
        __set__! name, value
      else
        raise ConditionError, 'deficent value for all conditions'
      end
    else
      __set__! name, value
    end
  end
  
  alias_method :assign, :__set__
  public :assign
  
  def __set__!(name, value)
    if procedure = self.class.procedures[name]
      value = instance_exec value, &procedure
    end
    
    @db[name] = value
  end
  
  def __subscript__(key)
    case key
    when Symbol, String
      name = key.to_sym
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
  
  def unlock
    @lock = false
    self
  end

end


end
