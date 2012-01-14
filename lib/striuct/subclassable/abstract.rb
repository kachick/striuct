require_relative 'classutil'
require_relative 'eigen'
autoload :YAML, 'yaml'


class Striuct


# @author Kenichi Kamiya
module Subclassable

  extend ClassUtil
  include Enumerable
  
  class << self
    private

    def included(klass)
      klass.extend Eigen
    end
  end
  
  def initialize(*values)
    @db = {}
    replace_values(*values)
  end
  
  # see self.class.*args
  delegate_class_methods(
    :members, :keys, :has_member?, :member?, :has_key?, :key?, :length,
    :size, :keyable_for, :restrict?, :has_default?, :default_for,
    :names, :has_flavor?, :flavor_for, :has_conditions?, :inference?,
    :conditions_for, :__orgkey_for__
  )
  
  private :keyable_for, :__orgkey_for__, :flavor_for, :conditions_for
  
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
    @db.hash
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
  # @return [value]
  def []=(key, value)
    __subscript__(key){|name|__set__ name, value}
  rescue ConditionError
    $@ = [
      "#{$@[-1].sub(/[^:]+\z/){''}}in `[]=': #{$!.message}",
      $@[-1]
    ]

    raise
  end

  alias_method :assign, :[]

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
    each_value.to_a
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
  
  # @return [String]
  def to_yaml
    YAML.__id__   # for autoload
    klass = Struct.new(*members)
    klass.new(*values).to_yaml
  end

  # @group Struct+ Safety
  
  # @param [Symbol, String] name
  # @param [Object] *values - no argument and use own
  def sufficient?(name, value=self[name])
    self.class.sufficient? name, value, self
  end
  
  alias_method :accept?, :sufficient?
  alias_method :valid?, :sufficient?

  def strict?
    each_pair.all?{|name, value|sufficient? name, value}
  end
  
  def secure?
    frozen? && self.class.closed? && strict?
  end

  # @endgroup
  
  # @group Struct + Handy
  
  # @yield [index] 
  # @yieldparam [Integer] index
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_index(&block)
    return to_enum(__method__) unless block_given?
    self.class.each_index(&block)
    self
  end

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
    name = __orgkey_for__(keyable_for name)
    
    @db.has_key? name
  end
  
  # @param [Symbol, String, Fixnum] key
  def clear_at(key)
    __subscript__(key){|name|__clear__ name}
  end
  
  alias_method :unassign, :clear_at
  alias_method :reset_at, :clear_at

  # @param [Symbol, String] name
  def default?(name)
    name = __orgkey_for__(keyable_for name)

    default_for(name) == self[name]
  end

  def empty?
    each_name.none?{|name|assign? name}
  end

  # @endgroup

  # @group HashLike

  # @yield [name] 
  # @yieldparam [Symbol] name - sequential under defined
  # @yieldreturn [self]
  # @return [Enumerator]
  def each_name(&block)
    return to_enum(__method__) unless block_given?
    self.class.each_name(&block)
    self
  end

  alias_method :each_member, :each_name
  alias_method :each_key, :each_name

  def has_value?(value)
    @db.has_value? value
  end

  alias_method :value?, :has_value?

  # @yield [name, value]
  # keep truthy only (unassign falsy member)
  # @see #each_pair
  # @return [Enumerator]
  # @yieldreturn [self]
  # @yieldreturn [nil]
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
  # @yield [name, value]
  # @return [Enumerator]
  def keep_if(&block)
    raise "can't modify frozen #{self.class}" if frozen?
    return to_enum(__method__) unless block_given?
    select!(&block)
    self
  end

  # @see #select!
  # keep falsy only (unassign truthy member)
  # @yield [name, value]
  # @return [Enumerator]
  def reject!
    raise "can't modify frozen #{self.class}" if frozen?
    return to_enum(__method__) unless block_given?

    modified = false
    each_pair do |name, value|
      if yield name, value
        unassign name
        modified = true
      end
    end
    
    modified ? self : nil
  end

  # @see #reject!
  # @yield [name, value]
  # @return [Enumerator]
  def delete_if(&block)
    raise "can't modify frozen #{self.class}" if frozen?
    return to_enum(__method__) unless block_given?

    reject!(&block)
    self
  end

  # @param [Symbol, String] name
  # @return [Array] [name, value]
  def assoc(name)
    name = __orgkey_for__(keyable_for name)

    [name, self[name]]
  end

  # @return [Array] [name, value]
  def rassoc(value)
    each_pair.find{|pair|pair[1] == value}
  end

  # @see Hash#flatten
  # @return [Array]
  def flatten(level=1)
    each_pair.to_a.flatten level
  end

  # @see #select!
  # @yield [name, value]
  # @return [Subclass]
  def select(&block)
    return to_enum(__method__) unless block_given?

    dup.tap {|r|r.select!(&block)}
  end

  # @see #reject!
  # @yield [name, value]
  # @return [Subclass]
  def reject(&block)
    return to_enum(__method__) unless block_given?

    dup.tap {|r|r.reject!(&block)}
  end

  # @endgroup

  private
  
  def initialize_copy(original)
    @db = @db.dup
  end

  def __get__(name)
    name = __orgkey_for__(keyable_for name)

    @db[name]
  end

  def __set__(name, value)
    raise "can't modify frozen #{self.class}" if frozen?
    name = __orgkey_for__(keyable_for name)

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
  rescue ConditionError
    unless /in \[\]=/ =~ caller[1].slice(/([^:]+)\z/)
      $@.delete_if{|s|/#{Regexp.escape(File.dirname __FILE__)}/ =~ s}
      $@.first.sub!(/([^:]+)\z/){"in `#{name}='"}
      $@ << $@.last
    end
  
    raise
  end
  
  def __subscript__(key)
    case key
    when Symbol, String
      name = keyable_for key
      if member? name
        yield __orgkey_for__(name)
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
  
  # @param [Symbol] name
  def __clear__(name)
    raise "can't modify frozen #{self.class}" if frozen?
    
    @db.delete name
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
