# Copyright (C) 2011  Kenichi Kamiya

require_relative 'subclassable/eigen'
require_relative 'subclassable/abstract'

# @author Kenichi Kamiya
# @abstract
class Striuct

  class ConditionError < ArgumentError; end

  class << self

    # @group Constructor
    
    alias_method :new_instance, :new
    private :new_instance
    
    # @param [Symbol, String] *names
    # @return [Class] - with Subclass, Subclass:Eigen
    def new(*names, &block)
      # warning for Ruby's Struct.new user
      arg1 = names.first
      if arg1.instance_of?(String) and /\A[A-Z]/ =~ arg1
        warn "no define constant #{arg1}"
      end

      Class.new self do
        names.each do |name|
          member name
        end

        class_eval(&block) if block_given?
      end
    end

    # @yieldreturn [Class] (see Striuct.new) - reject floating class
    # @return [void]
    def define(&block)
      raise ArgumentError, 'must with block' unless block_given?

      new(&block).tap do |subclass|
        subclass.instance_eval do
          raise 'not yet finished' if members.empty?
          close
        end
      end
    end

    # @groupend

    private
    
    def inherited(subclass)
      subclass.class_eval do
        extend  Subclassable::Eigen
        include Subclassable
      end
    end
  end

end