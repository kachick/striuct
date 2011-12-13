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
    def new(*names, &block)
      if names.first.instance_of? String
        warn "no define constant #{names.first}"
      end

      Class.new self do
        names.each do |name|
          member name
        end

        class_eval(&block) if block_given?
      end
    end

    # @return [SubClass]
    def load_pairs(pairs, &block)
      raise ArgumentError unless pairs.respond_to? :each_pair

      new do
        pairs.each_pair do |name, conditions|
          member(name, *conditions)
        end
        
        class_eval(&block) if block_given?
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