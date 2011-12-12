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
    User3 = Striuct.new do
      member :name, /\A\w+\z/, /\A\w+ \w+\z/
    end
    
    p User3.conditions

# * but always destroy Ruby's objects... you can use easy_check all time
    p user.strict?
    user.last_name.clear
    p user.strict?

