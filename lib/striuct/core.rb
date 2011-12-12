# Copyright (C) 2011  Kenichi Kamiya

require_relative 'subclass_eigen'
require_relative 'subclass'

# @author Kenichi Kamiya
class Striuct

  class ConditionError < ArgumentError; end

  class << self
    alias_method :new_instance, :new
    private :new_instance
    
    # @return [SubClass]
    def new(*members, &block)
      if members.first.instance_of? String
        warn "no define constant #{members.first}"
      end

      Class.new self do |klass|
        members.each do |m|
          member m
        end
        
        instance_exec(klass, &block) if block_given?
      end
    end
  
    # @return [SubClass]
    def load_pairs(pairs, &block)
      new do |klass|
        pairs.each do |k, v|
          member k, v
        end
        
        instance_exec(klass, &block) if block_given?
      end
    end
    
    private
    
    def inherited(subclass)
      subclass.class_eval do
        include SubClass
        extend SubClass::Eigen
  
        @members = []
        @conditions = {}
      end
    end
  end

end

StrictStruct = Striuct