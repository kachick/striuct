#/usr/bin/ruby -w

require_relative 'lib/striuct'

def debug(message)
  puts "line: #{caller[0].slice(/:(\w+)/, 1)}"
  puts message.inspect, '-' * 80
end

#* Macro "member" provides one of Struct+ interfaces for condtions and a flavor.
class User < Striuct.new
  member :id, Integer
  member :address, /\A((\w+) ?)+\z/
  member :age, (20..140)
  member :name, /\A\w+\z/, /\A\w+ \w+\z/
end

# pass
user = User.new 128381, 'Tokyo Japan', 20
debug user

# pass
user.age = 30
user.name = 'taro yamada'
debug user

# fail (Exception  Striuct::ConditionError)
begin
  user[:id] = 10.0
rescue
  debug $!
end

begin
  user[1] = 'Tokyo-to'
rescue
  debug $!
end

begin
  user.age = 19
rescue
  debug $!
end

begin
  user.name = nil
rescue
  debug $!
end

#* but, linked objects are able to clash
debug user
debug user.strict?
debug user
debug user.strict?

#* more detail checker do you need, you can use functional object.
module Game
  class Character
  end

  class DB < Striuct.new
    member :monsters, ->monsters{(monsters - characters).empty?}
    member :characters, ->characters{characters.all?{|c|c.kind_of? Character}}
  end
  
  monster = Character.new
  db = DB.new
  
  begin
    db.characters = [1, 2]
  rescue
    debug $!
  end
  
  db.characters = [monster, Character.new]
  debug db
  
  begin
    db.monsters = [:dummy]
  rescue
    debug $!
  end
  
  db.monsters = [monster]
  debug db
end

 
#* with flavor for type cast
class User2 < Striuct.new
  member :age, /\A\d+\z/, Numeric do |arg|
    Integer arg
  end
  
  member :name, ->v{v.respond_to? :to_str} do |v|
    v.to_str.to_sym
  end
end

user2 = User2.new
user2.age = 9
debug user2

user2.age = 10.1
debug user2

user2.age = '10'
debug user2

begin
  user2.name = 10
rescue
  debug $!
end

user2.name = 's'
debug user2.class

#* use default value
class User3 < Striuct.new
  member  :lank, Fixnum
  default :lank, 3
  member  :name
end

user3 = User3.new
user3
debug user3

# Standard Struct always define "nil is default". ...realy?
debug user3.assign?(:name)
user3.name = nil
debug user3.assign?(:name)

#* and keeping Struct's good interface
Sth1 = Striuct.new :id, :last_name, :family_name, :address, :age

debug Sth1.new

Sth2 = Striuct.new do
  def my_special_method
  end
end

debug Sth2.new.respond_to?(:my_special_method)