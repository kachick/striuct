class Striuct

# @author Kenichi Kamiya
module StructExtension

  module Eigen
    def has_member?(name)
      members.include? name
    end

    alias_method :member?, :has_member?
    alias_method :has_key?, :has_member?
    alias_method :key?, :has_key?

    def has_condition?(name)
      false
    end
    
    alias_method :restrict?, :has_condition?

    def conditionable?(condition)
      false
    end
    
    def sufficient?(name, value, context=self)
      true
    end
    
    alias_method :accept?, :sufficient?

    def has_default?(name)
      false
    end
    
    def cname?(name)
      [Symbol, String].any?{|klass|name.instance_of? klass}
    end

    def has_flavor?(name)
      false
    end

    def names
      members
    end

    alias_method :keys, :names

    def each_name(&block)
      return to_enum(__method__) unless block_given?
      names.each(&block)
      self
    end

    alias_method :each_member, :each_name
    alias_method :each_key, :each_name

    # @return [Struct]
    def load_pairs(pairs)
      unless pairs.respond_to?(:each_pair) and pairs.respond_to?(:keys)
        raise TypeError, 'no pairs object'
      end

      raise ArgumentError, "different members" unless (pairs.keys - keys).empty?

      new.tap {|instance|
        pairs.each_pair do |name, value|
          instance[name] = value
        end
      }
    end

    def define(lock=true)
      raise ArgumentError, 'must with block' unless block_given?
    
      new.tap {|instance|
        yield instance

        instance.freeze if lock
      }
    end

    def closed?
      true
    end
    
    def infelence?
      false
    end

  end

  def strict?
    false
  end

  def secure?
    false
  end

  # @return [Hash]
  def to_h
    {}.tap {|h|
      each_pair do |k, v|
        h[k] = v
      end
    }
  end
end


end


class Struct
  extend  Striuct::StructExtension::Eigen
  include Striuct::StructExtension
end
