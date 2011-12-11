# Copyright (C) 2011  Kenichi Kamiya

# @author Kenichi Kamiya
class Striuct
  include Enumerable
  
  VERSION = '0.0.3'.freeze
  Version = VERSION
  
  module Exceptions
    class ConditionError < ArgumentError; end
  end

  include Exceptions

  class << self
    include Exceptions

    alias_method :new_instance, :new
    private :new_instance

    def new(*members, &block)
      Class.new self do |klass|
        members.each do |m|
          member m
        end
        
        instance_exec(klass, &block) if block_given?
      end
    end
    
    def load_pairs(pairs, &block)
      new do |klass|
        pairs.each do |k, v|
          member k, v
        end
        
        instance_exec(klass, &block) if block_given?
      end
    end
    
    private
        
    def delegate_class_method(name)
      define_method name do |*args, &block|
        self.class.__send__ name, *args, &block
      end
    end
    
    def delegate_class_methods(*names)
      raise ArgumentError unless names.length >= 1
      
      names.each{|name|delegate_class_method name}
    end
  end
  
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
  
  def hash
    values.map(&:hash).hash
  end
  
  def strict?
    true
  end
end

StrictStruct = Striuct