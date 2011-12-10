# Copyright (C) 2011  Kenichi Kamiya

# @author Kenichi Kamiya
class Striuct
  include Enumerable
  
  VERSION = '0.0.2'.freeze
  Version = VERSION
  
  module Exceptions
    class ConditionIsNotSatisfied < ArgumentError; end
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
  end
end

StrictStruct = Striuct