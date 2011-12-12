require_relative 'classutil'

class Striuct


# @author Kenichi Kamiya
module SubClass

  extend ClassUtil
  include Enumerable
  
  def initialize(*values)
    if values.size <= members.size
      values.each_with_index do |v, idx|
        __send__ :"#{members[idx]}=", v
      end
    else
      raise ArgumentError
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
      members.each_with_index do |m, idx|
        s << " [#{idx}, #{m}, #{conditions[m].inspect}]=#{self[m].inspect}\n"
      end
      
      s << '#>'
    end
  end

  # @return [String]
  def to_s
    "#<StrictStruct #{self.class}".tap do |s|
      members.each_with_index do |m, idx|
        s << " [#{idx}, #{m}]=#{self[m]}"
      end
      
      s << '>'
    end
  end

  delegate_class_methods(
    :members, :keys, :member?, :has_key?, :key?, :length,
    :size, :conditions
  )

  def [](key)
    case key
    when Symbol, String
      if member? key
        __send__ key
      else
        raise NameError
      end
    when Fixnum
      if member = members[key]
        __send__ member
      else
        raise IndexError
      end
    else
      raise ArgumentError
    end
  end
  
  # @return [value]
  def []=(key, value)
    case key
    when Symbol, String
      if member? key
        __send__ :"#{key}=", value
      else
        raise NameError
      end
    when Fixnum
      if member = members[key]
        __send__ :"#{member}=", value
      else
        raise IndexError
      end
    else
      raise ArgumentError
    end
    
    value
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

  def strict?
    each_pair.all? do |member, value|
      if list = conditions[member]
        list.any?{|condition|condition === value}
      else
        true
      end
    end
  end

end


end
