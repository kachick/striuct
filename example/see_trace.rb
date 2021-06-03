# frozen_string_literal: true
#/usr/bin/ruby -w

require_relative '../lib/striuct'

class User < Striuct.new
  member :id,   Integer
  member :age,  (20..140)
end

user = User.new

begin
  user[:id] = 10.0
rescue
  puts $!.backtrace
end

puts '-' * 80

$stdout.flush

begin
  user.age = 19
rescue
  puts $!.backtrace
end

puts '-' * 80

$stdout.flush

user.age = 19
