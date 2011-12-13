#!/usr/bin/ruby -w

require_relative 'lib/striuct'

# * basic
    class User < Striuct.new
      member :id, Integer
      member :last_name, /\A\w+\z/
      member :family_name, /\A\w+\z/
      member :address, /\A((\w+) ?)+\z/
      member(:age) {|v|(20..140).include? v}
    end

    # pass
    user = User.new 128381, 'bar', 'foo', 'Tokyo Japan', 20
    p user

    # fail (Exception)
    #~ user.age = 19

# * has API looks standard Struct
    User2 = Striuct.new :id, :last_name, :family_name, :address, :age

    p User2.members

# * mix
    UserStd = Struct.new :aaa do |klass|
      p klass.superclass
    end

    User3 = Striuct.new :something do |klass|
      p klass.superclass
      member :name, /\A\w+\z/, /\A\w+ \w+\z/
    end
    
    user3 = User3.new
    p user3


# * But, Ruby's objects always can be destroyed. Use easy checker for this case.
    p user.strict?
    user.last_name.clear
    p user.strict?


