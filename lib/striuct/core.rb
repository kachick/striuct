# Copyright (C) 2011  Kenichi Kamiya

require_relative 'subclass_eigen'
require_relative 'subclass'

# @author Kenichi Kamiya
class Striuct

  class ConditionError < ArgumentError; end
  class LockError < RuntimeError; end

  class << self
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

    # @return [Class] (see Striuct.new) - reject floating class
    def define(&block)
      new(&block).tap do |subclass|
        subclass.instance_eval do
          raise 'not yet finished' if members.empty?
          lock
        end
      end
    end

    private
    
    def inherited(subclass)
      subclass.class_eval do
        extend Subclass::Eigen
        include Subclass
      end
    end
  end

end
