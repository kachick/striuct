#/usr/bin/ruby -w

require_relative 'lib/striuct'

def debug(message)
  puts "line: #{caller.first.slice(/:(\w+)/, 1)}"
  puts message.inspect, '-' * 80
end


# 1. Struct+ "Secure"

# macro "member" provides to use condtions
class User < Striuct.new
  member :id,   Integer
  member :age,  (20..140)
  member :name, /\A\w+\z/, /\A\w+ \w+\z/
end

user = User.new 128381, 20
debug user

user.age = 30
user[2] = 'taro yamada'
debug user

# fail (Exception  Striuct::ConditionError)
begin
  user[:id] = 10.0
rescue
  debug $!
end

begin
  user.age = 19
rescue
  debug $!
end

begin
  user[2] = 'typo! name'
rescue
  debug $!
end

# more detail checker do you need, use functional object
module Game
  class Character
  end

  class DB < Striuct.new
    member :monsters,   ->list{(list - characters).empty?}
    member :characters, ->list{list.all?{|c|c.kind_of? Character}}
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
    db.monsters = [Character.new]
  rescue
    debug $!
  end
  
  db.monsters = [monster]
  debug db
end

# through "inference", and check under first passed object class
class FlexibleContainer < Striuct.new
  member :anything, inference
  member :number,   inference, Numeric
end

fc1, fc2 = FlexibleContainer.new, FlexibleContainer.new
fc1.anything = 'str'
debug fc1
begin
  fc1.anything = :sym
rescue
  debug $!
end

begin
  fc2.anything = :sym
rescue
  debug $!
end

fc2.anything = 'string too'

debug fc2

begin
  fc1.number = 'str'
rescue
  debug $!
end

fc1.number = 1.0
debug fc1

begin
  fc2.number = 1
rescue
  debug $!
end

# Standard Struct not check member name. 
NoGuard = Struct.new :__send__, :'?  !'
noguard = NoGuard.new false
debug noguard.__send__
debug noguard.methods.include?(:'?  !') # lost!!

# Striuct provides safety levels for naming.
class SafetyNaming < Striuct.new
  begin
    member :__send__
  rescue
    debug $!
  end
  
  begin
    member :'?  !'
  rescue
    debug $!
  end
  
  # set lower
  protect_level :struct
  
  member :__send__, :'?  !'
end

# 2. Struct+ "Handy"

# to through block called "flavor"
# below case for type cast
class User2 < Striuct.new
  member :age, /\A\d+\z/, Numeric do |arg|
    Integer arg
  end
  
  member :name, ->v{v.respond_to? :to_s} do |v|
    v.to_s.to_sym
  end
end

user2 = User2.new
user2.age = 9
debug user2

user2.age = 10.1
debug user2

user2.age = '10'
debug user2

user2.name = 10
debug user2
user2.name = Class
debug user2

# Default value

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

# Alias

class User3
  alias_member :position, :lank
end

debug user3.lank.equal?(user3.position)
debug user3[:lank].equal?(user3[:position])
user3[:position] = 4
debug user3.lank

# New Constructors

# Subclass.define reject floating object
# * except if no finished assign each members
# * return object is frozen
user3 = User3.define do |r|
  r.lank = 10
  r.name = 'foo'
end

debug user3

# Subclass.load_pairs easy make from Hash and like Hash
user3 = User3[lank:10, name: 'foo']

debug user3

# 3. Keeping Struct's good interface

Sth1 = Striuct.new do
  def my_special_method
  end
end

debug Sth1.new.respond_to?(:my_special_method)