#!/usr/bin/ruby -w

require_relative 'lib/striuct'

# * basic
    class User < Striuct.new
      member :id, Integer
      member :last_name, /\A\w+\z/
      member :family_name, /\A\w+\z/
      member :address, /\A((\w+) ?)+\z/
      member :age, ->age{(20..140).include? age}
    end

    # pass
    user = User.new 128381, 'bar', 'foo', 'Tokyo Japan', 20
    p user
    
    user.age = 80
    p user

    begin
      user.age = 19
    rescue
      p $!
    end

# * has API looks standard Struct
    User2 = Striuct.new :id, :last_name, :family_name, :address, :age

    p User2.members

    UserStd = Struct.new :aaa do |klass|
      p klass.superclass
    end

    User3 = Striuct.new :something do |klass|
      p klass.superclass
      member :name, /\A\w+\z/, /\A\w+ \w+\z/
    end
    
    user3 = User3.new
    p user3
    user3[0] = nil
    p user3

# * But, Ruby's objects always can be destroyed. Use easy checker for this case.
    p user.strict?
    user.last_name.clear
    p user.strict?

# This class not only strict. You can use procedure for setter.
    class User4 < Striuct.new
      member :age, /\A\d+\z/, Numeric do |arg|
        Integer arg
      end
    end
    
    user4 = User4.new
    user4.age = 9
    p user4.age
    user4.age = 10.1
    p user4.age
    p user4.age.class
    user4.age = '10'
    p user4.age
    p user4.age.class