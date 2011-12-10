#!/usr/bin/ruby -w

require_relative 'lib/striuct'

class User < Striuct.new
  member :id, Integer
  member :last_name, /\A\w+\z/
  member :family_name, /\A\w+\z/
  member :address, /\A((\w+) ?)+\z/
  member(:age) {|v|(20..140).include? v}
end

# pass
user = User.new 128381, 'bar', 'foo', '1-1-1 Town Tokyo', 20
p user

# fail (Exception)
user.age = 19
