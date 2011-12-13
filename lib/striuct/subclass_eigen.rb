# Copyright (C) 2011  Kenichi Kamiya

class Striuct; module SubClass


module Eigen
  # @return [instance]
  def new(*values)
    new_instance(*values)
  end

  # @return [instance]
  def load_pairs(pairs)
    raise ArgumentError unless pairs.respond_to? :each_pair

    new.tap do |r|
      pairs.each_pair do |key, value|
        if member? key
          r[key] = value
        else
          raise ArgumentError
        end
      end
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
  
  alias_method :keys, :members
  
  def member?(key)
    case key
    when Symbol, String
      @members.include? key.to_sym
    else
      false
    end
  end
  
  alias_method :has_key?, :member?
  alias_method :key?, :has_key?

  # @return [self]
  def each_member(&block)
    return to_enum(__method__) unless block_given?
    members.each(&block)
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
  def define_member(key, *conditions, &block)    
    case key
    when Symbol
    when String
      key = key.to_sym
    else
      raise ArgumentError
    end

    unless member? key
      @members << key
      define_reader key
      define_writer key, *conditions, &block
    else
      raise ArgumentError
    end
    
    nil
  end

  alias_method :def_member, :define_member
  alias_method :member, :define_member

  # @macro define_members
  # @return [nil]
  def define_members(*names)
    raise ArgumentError "wrong number of arguments (0 for 1+)" unless names.length >= 1
    
    names.each do |name|
      define_member name
    end

    nil
  end

  alias_method :def_members, :define_members

  # @macro define_pairs
  # @return [nil]
  def define_pairs(pairs)
    raise ArgumentError unless pairs.respond_to? :each_pair

    pairs.each_pair do |k, v|
      define_member k, v
    end
    
    nil
  end
  
  alias_method :def_pairs, :define_pairs

  # @macro define_reader
  # @return [nil]
  def define_reader(key)
    raise ArgumentError unless key.instance_of? Symbol
    
    define_method key do
      if instance_variable_defined? :"@#{key}"
        instance_variable_get :"@#{key}"
      else
        nil
      end
    end
    
    nil
  end

  # @macro define_writer
  # @return [nil]
  # @raise [ConditionError] argument unmatch all conditions or block
  def define_writer(key, *conditions, &block)
    raise ArgumentError unless key.instance_of? Symbol
  
    if conditions.empty?
      if block_given?
        @conditions[key] = [block]
        
        define_method "#{key}=" do |value|
          if block.call value
            instance_variable_set :"@#{key}", value
          else
            raise ConditionError
          end
        end
      else
        define_method "#{key}=" do |value|
          instance_variable_set :"@#{key}", value
        end
      end
    else
      if block_given?
        raise ArgumentError, 'Could not use arguments with block'
      else
        @conditions[key] = conditions

        define_method "#{key}=" do |value|
          if conditions.any?{|condition|condition === value}
            instance_variable_set :"@#{key}", value
          else
            raise ConditionError
          end
        end
      end
    end
    
    nil
  end

end


end; end
