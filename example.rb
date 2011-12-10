#!/usr/bin/ruby -w

require_relative 'lib/striuct'

class Foo < Struct.new :ad
end

class User < Striuct.new
end

p Struct.methods(false)
p Foo.ancestors
p Foo.instance_variables
p Foo.methods(true).include?(:members)

puts '------------'
p Striuct.methods(false)
p User.ancestors
#~ User.instance_variable_set :"@members", []
p User.instance_variables
p User.methods(true).include?(:members)

puts '------------'
p User.methods(true)
puts '------------'


class User
  member :id, Integer
  member :last_name, /\A\w+\z/
  member :family_name, /\A\w+\z/
  member :address, /\A((\w+) ?)+\z/
  member(:age) {|v|(20..140).include? v}
end

#~ User = Striuct.new

# pass
#~ user = User.new 128381, 'bar', 'foo', '1-1-1 Town Tokyo', 20
#~ user = User.new :id => 128381
user = User.new 7676
p user

# fail
user[:age] = 32
p user

user[4] = 66
p user