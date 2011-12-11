# Copyright (C) 2011  Kenichi Kamiya

require_relative 'core'

class << Striuct
  private

  def inherited(subclass)
    subclass.class_eval do
      @members = []
      @conditions = {}

      def initialize(*values)
        if values.size <= members.size
          values.each_with_index do |v, idx|
            __send__ :"#{members[idx]}=", v
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
        
        def conditions
          @conditions.dup
        end
        
        alias_method :keys, :members
        
        def member?(key)
          @members.include? key.to_sym
        end
        
        alias_method :has_key?, :member?
        alias_method :key?, :has_key?
        
        def each_member(&block)
          return to_enum(__method__) unless block_given?
          members.each(&block)
        end
        
        alias_method :each_key, :each_member
        
        def length
          @menbers.length
        end
        
        alias_method :size, :length
        
        private

        def define_member(key, *conditions, &block)
          case key
          when Symbol
          when String
            key = key.to_sym
          else
            raise ArgumentError
          end

          unless @members.include? key
            @members << key
            define_reader key
            define_writer key, *conditions, &block
          else
            raise ArgumentError
          end
        end

        alias_method :def_member, :define_member
        alias_method :member, :define_member
        
        def define_members(*names)
          names.each_pair do |name|
            define_member name
          end
        end
  
        alias_method :def_members, :define_members
  
        def define_pairs(pairs)
          pairs.each_pair do |k, v|
            define_member k, v
          end
        end
        
        alias_method :def_pairs, :define_pairs
        
        def define_reader(key)
          define_method key do
            if instance_variable_defined? :"@#{key}"
              instance_variable_get :"@#{key}"
            else
              nil
            end
          end
        end
        
        def define_writer(key, *conditions, &block)
          if conditions.empty?
            if block_given?
              @conditions[key] = block
              
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
              raise ArgumentError
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
        end
      end
      
      def inspect
        "#<#{self.class} (StrictStruct)\n".tap do |s|
          members.each_with_index do |m, idx|
            s << " [#{idx}, #{m}, #{conditions[m].inspect}]=#{self[m].inspect}\n"
          end
          
          s << '#>'
        end
      end
      
      def to_s
        "#<StrictStruct #{self.class}".tap do |s|
          members.each_with_index do |m, idx|
            s << " [#{idx}, #{m}]=#{self[m]}"
          end
          
          s << '>'
        end
      end

      delegate_class_methods(
        :members, :keys, :member?, :has_key?, :key?, :length,
        :size, :conditions, :each_member, :each_key
      )

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
      
      def each_value
        return to_enum(__method__) unless block_given?
        each_member{|member|yield self[member]}
      end
      
      alias_method :each, :each_value
      
      def each_pair
        return to_enum(__method__) unless block_given?
        each_member{|member|yield member, self[member]}
      end
      
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
