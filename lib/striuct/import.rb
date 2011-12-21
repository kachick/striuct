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
    
    def sufficent?(name, value)
      true
    end
    
    alias_method :accept?, :sufficent?

    def has_default?(name)
      false
    end
    
    def cname?(name)
      [Symbol, String].any?{|klass|name.instance_of? klass}
    end

    def has_flavor?(name)
      false
    end

    # @return [Struct]
    def load_pairs(pairs)
      raise TypeError, 'no pairs object' unless pairs.respond_to? :each_pair

      new.tap do |r|
        pairs.each_pair do |name, value|
          if member? name
            r[name] = value
          else
            raise ArgumentError, " #{name} is not our member"
          end
        end
      end
    end
    
    def define(lock=false)
      raise ArgumentError unless lock.equal?(false)

      new.tap{|instance|yield instance}
    end

    # @return [StrictStruct]
    def to_strict
      StrictStruct.new(*members)
    end
    
    def closed?
      true
    end
  end

  def assign?(name)
    ! self[name].nil?
  end

  def strict?
    false
  end

  def secure?
    false
  end

end


end


class Struct
  extend Striuct::StructExtension::Eigen
  include Striuct::StructExtension
end