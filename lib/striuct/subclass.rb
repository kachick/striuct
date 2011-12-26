require_relative 'classutil'

class Striuct


# @author Kenichi Kamiya
module Subclass

  extend ClassUtil
  include Enumerable
  
  def initialize(*values)
    @db = {}
    replace_values(*values)
  end
  
  # see self.class.*args
  delegate_class_methods(
    :members, :keys, :has_member?, :member?, :has_key?, :key?, :length,
    :size, :keyable_for, :restrict?, :has_default?, :default_for,
    :names, :has_flavor?, :flavor_for, :has_conditions?, :inference?,
    :conditions_for
  )
  
  private :keyable_for, :flavor_for, :conditions_for
  
  # @return [Boolean]
  def ==(other)
    __compare_all__ other, :==
  end

  alias_method :===, :==
  
  def eql?(other)
    __compare_all__ other, :eql?
  end

  # @return [Integer]
  def hash
    [self.class, @db].hash
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

  # @param [Symbol, String, Fixnum] key
  def [](key)
    __subscript__(key){|name|__get__ name}
  end
  
  # @param [Symbol, String, Fixnum] key
  # @param [Object] value
  def []=(key, value)
    __subscript__(key){|name|__set__ name, value}
  end

  # @yield [value]
  # @yieldparam [Object] value - sequential under defined
  # @see #each_name
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_value
    return to_enum(__method__) unless block_given?
    each_member{|member|yield self[member]}
  end
  
  alias_method :each, :each_value

  # @yield [name, value]
  # @yieldparam [Symbol] name
  # @yieldparam [Object] value
  # @yieldreturn [self]
  # @return [Enumerator]
  # @see #each_name
  # @see #each_value 
  def each_pair
    return to_enum(__method__) unless block_given?
    each_name{|name|yield name, self[name]}
  end

  # @return [Array]
  def values
    [].tap {|r|
      each_value do |v|
        r << v
      end
    }
  end
  
  alias_method :to_a, :values

  # @param [Fixnum, Range] *keys
  # @return [Array]
  def values_at(*keys)
    [].tap {|r|
      keys.each do |key|
        case key
        when Fixnum
          r << self[key]
        when Range
          key.each do |n|
            raise TypeError unless n.instance_of? Fixnum
            r << self[n]
          end
        else
          raise TypeError
        end
      end
    }
  end

  # @return [self]
  def freeze
    @db.freeze
    super
  end

  # @group Struct+

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

  # @return [Hash]
  def to_h(reject_no_assign=false)
    return @db.dup if reject_no_assign

    {}.tap {|h|
      each_pair do |k, v|
        h[k] = v
      end
    }
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
  def sufficient?(name, value=self[name])
    self.class.sufficient? name, value, self
  end
  
  alias_method :accept?, :sufficient?

  def strict?
    each_pair.all?{|name, value|sufficient? name, value}
  end
  
  def secure?
    frozen? && self.class.closed? && strict?
  end
  
  # @param [Symbol, String] name
  def default?(name)
    default_for(name) == self[name]
  end

  def has_value?(value)
    @db.has_value? value
  end

  alias_method :value?, :has_value?

  def empty?
    each_name.none?{|name|assign? name}
  end

  # @see Hash#select!
  # unassign false member
  def select!
    raise "can't modify frozen #{self.class}" if frozen?
    return to_enum(__method__) unless block_given?

    modified = false
    each_pair do |name, value|
      unless yield name, value
        unassign name
        modified = true
      end
    end
    
    modified ? self : nil
  end

  # @see #select!
  # always return self
  def keep_if(&block)
    raise "can't modify frozen #{self.class}" if frozen?
    return to_enum(__method__) unless block_given?
    select!(&block)
    self
  end

  # @endgroup

  private
  
  def initialize_copy(original)
    @db = @db.dup
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

    unless accept? name, value
      raise ConditionError,
            "#{value.inspect} is deficient for #{conditions_for(name).inspect}"
    end
          
    if has_flavor? name
      value = instance_exec value, &flavor_for(name)
    end

    if inference? name
      self.class.__send__ :__found_family__!, self, name, value
    end
    
    @db[name] = value
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

  def replace_values(*values)
    unless values.size <= size
      raise ArgumentError, "struct size differs (max: #{size})"
    end

    values.each_with_index do |value, index|
      self[index] = value
    end
      
    excess = members.last(size - values.size)
      
    excess.each do |name|
      self[name] = default_for name if has_default? name
    end
  end

  # @param [Symbol] method
  def __compare_all__(other, method)
    instance_of?(other.class) && \
    each_pair.all?{|k, v|v.__send__ method, other[k]}
  end
  
end


end
