class Striuct; module StructExtension


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
  
  def conditions
    {}
  end
  
  def procedures
    {}
  end
  
  def defaults
    {}
  end
  
  def define(lock=false)
    raise ArgumentError unless lock.equal?(false)

    new.tap{|instance|yield instance}
  end
  
  def to_strict
    StrictStruct.new(*members)
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

def lock?
  false
end


end; end


class Struct
  extend Striuct::StructExtension::Eigen
  include Striuct::StructExtension
end