class Striuct; module Containable
  # @group Basic
  
  def initialize(*values)
    @db, @locks = {}, {}
    replace_values(*values)
  end

  # see self.class.*args
  delegate_class_methods(
    :members, :keys, :names,
    :has_member?, :member?, :has_key?, :key?,
    :length, :size
  )
  
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
    "#<#{self.class} (Striuct)".tap do |s|
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
    true_name = nil
    __subscript__(key){|name|true_name = name; __set__ name, value}
  rescue ConditionError
    $@ = [
      "#{$@[-1].sub(/[^:]+\z/){''}}in `[#{key.inspect}(#{true_name})]=': #{$!.message}",
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
    [@db, @locks].each(&:freeze)
    super
  end

  # @endgroup
end; end