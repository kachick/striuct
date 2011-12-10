# Copyright (C) 2011  Kenichi Kamiya

# @author Kenichi Kamiya
class Striuct
  include Enumerable
  
  VERSION = '0.0.1'.freeze
  Version = VERSION

  class << self
    class ConditionIsNotSatisfied < ArgumentError; end

    alias_method :new_instance, :new

    def new(pairs=nil, *members)
      Class.new self do
        if pairs
          pairs.each do |key, value|
            member key, value
          end
        else
          members.each do |m|
            member m
          end
        end
      end
    end
    
    private :new_instance
  end
end

StrictStruct = Striuct