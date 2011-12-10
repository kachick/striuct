# Copyright (C) 2011  Kenichi Kamiya

require_relative 'core'

class << Striuct
  private

  def inherited(subclass)
    subclass.class_eval do
      @members = []

      def initialize(*values)
        if values.size <= members.size
          values.each_with_index do |v, idx|
            instance_variable_set :"@#{members[idx]}", v
          end
        else
          raise ArgumentError
        end
      end

      singleton_class.class_eval do
        def new(*args)
          new_instance(*args)
        end
        
        def load_pairs(pairs)
          new.tap do |r|
            if pairs.respond_to? :each_pair
              pairs.each_pair do |key, value|
                if members.include? key
                  r[key] = value
                else
                  raise ArgumentError
                end
              end
            else
              raise ArgumentError
            end
          end
        end
        
        def members
          @members.dup
        end
        
        def member?(key)
          @members.include? key.to_sym
        end
        
        private

        def define_member(key, condition=nil, &block)
          case key
          when Symbol
          when String
            key = key.to_sym
          else
            raise ArgumentError
          end

          @members << key
          define_reader key
          define_writer key, condition, &block
        end

        alias_method :def_member, :define_member
        alias_method :member, :define_member
        
        def define_members(pairs)
          pairs.each do |k, v|
            define_member k, v
          end
        end
        
        alias_method :def_members, :define_members
        
        def define_reader(key)
          define_method key do
            instance_variable_get :"@#{key}"
          end
        end
        
        def define_writer(key, condition=nil, &block)
          define_method "#{key}=" do |value|
            raise ArgumentError if condition and block_given?
            
            if block_given?
              if block.call value
                instance_variable_set :"@#{key}", value
              else
                raise ConditionIsNotSatisfied
              end
            end
            
            if condition.nil?
              instance_variable_set :"@#{key}", value
            else
              if condition === value
                instance_variable_set :"@#{key}", value
              else
                raise ConditionIsNotSatisfied
              end
            end
          end
        end
      end
      
      def members
        self.class.members
      end
      
      def member?(key)
        self.class.member? key
      end
      
      alias_method :has_key?, :member?
      alias_method :key?, :has_key?

      def [](key)
        case key
        when Symbol, String
          if member? key
            __send__ key
          else
            raise NameError
          end
        when Fixnum
          if member = members[key]
            __send__ member
          else
            raise IndexError
          end
        else
          raise ArgumentError
        end
      end
      
      def []=(key, value)
        case key
        when Symbol, String
          if member? key
            __send__ :"#{key}=", value
          else
            raise NameError
          end
        when Fixnum
          if member = members[key]
            __send__ :"#{member}=", value
          else
            raise IndexError
          end
        else
          raise ArgumentError
        end
      end
      
      def each_member(&block)
        members.each(&block)
      end
      
      alias_method :each_key, :each_member
      
      def each_value
        each_member{|member|yield self[member]}
      end
      
      alias_method :each, :each_value
      
      def values
        [].tap do |r|
          each_value do |v|
            r << v
          end
        end
      end
      
      alias_method :to_a, :values
      
      def values_at(*members)
        [].tap do |r|
          members.each do |member|
            r << self[member]
          end
        end
      end
    end
  end
end
