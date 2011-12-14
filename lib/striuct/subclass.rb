require_relative 'classutil'

class Striuct


# @author Kenichi Kamiya
module SubClass

  extend ClassUtil
  include Enumerable
  
  def initialize(*values)
    @db, @lock = {}, false
    
    if values.size <= members.size
      values.each_with_index do |v, idx|
        __send__ :"#{members[idx]}=", v
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
    "#<#{self.class} (StrictStruct)".tap do |s|
      members.each_with_index do |name, idx|
        s << "\n #{idx.to_s.rjust 3}. #{name}\n"
        s << "#{' ' * 8}conditions : #{conditions[name].inspect}\n"
        s << "#{' ' * 8}value      : #{self[name].inspect}"
      end
      
      s << "\n>"
    end
  end

  # @return [String]
  def to_s
    "#<struct #{self.class}".tap do |s|
      members.each_with_index do |m, idx|
        s << " [#{idx}, #{m}]=#{self[m]}"
      end
      
      s << '>'
    end
  end

  delegate_class_methods(
    :members, :keys, :has_member?, :member?, :has_key?, :key?, :length,
    :size, :conditions
  )

  def [](key)
    __subscript__(key){|name|__get__ name}
  end
  
  # @return [value]
  def []=(key, value)
    __subscript__(key){|name|__set__ name, value}
  end

  # @return [self]
  def each_member
    return to_enum(__method__) unless block_given?
    self.class.each_member{|member|yield member}
    self
  end
  
  alias_method :each_key, :each_member

  # @return [self]
  def each_value
    return to_enum(__method__) unless block_given?
    each_member{|member|yield self[member]}
  end
  
  alias_method :each, :each_value

  # @return [self]
  def each_pair
    return to_enum(__method__) unless block_given?
    each_member{|member|yield member, self[member]}
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
  def values_at(*members)
    [].tap do |r|
      members.each do |member|
        r << self[member]
      end
    end
  end

  def sufficent?(name)
    self.class.__send__(__method__, name, self[name])
  end

  def strict?
    each_pair.all?{|name, value|self.class.sufficent? name, value}
  end

  # @return [nil]
  def lock
    @lock = true
    nil
  end

  # @return [nil]
  def unlock
    @lock = false
    nil
  end
  
  def lock?
    @lock
  end
  
  def secure?
    lock? && strict?
  end

  private

  def __get__(name)
    @db[name]
  end

  def __set__(name, value)
    raise LockError if lock?

    if member? name
      if self.class.sufficent? name, value
        @db[name] = value
      else
        raise ConditionError, 'deficent value for all conditions'
      end
    else
      @db[name] = value
    end
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

end


end
