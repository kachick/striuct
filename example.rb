#/usr/bin/ruby -w

require_relative 'lib/striuct'

#* Macro "member" provides one of Struct+ interfaces for condtions and a procedure.
    class User < Striuct.new
      member :id, Integer
      member :address, /\A((\w+) ?)+\z/
      member :age, (20..140)
      member :name, /\A\w+\z/, /\A\w+ \w+\z/
    end

    # pass
    user = User.new 128381, 'Tokyo Japan', 20
    p user

    # pass
    user.age = 30
    user.name = 'taro yamada'
    p user

    # fail (Exception  Striuct::ConditionError)
    begin
      user[:id] = 10.0
    rescue
      p $!
    end
    
    begin
      user[1] = 'Tokyo-to'
    rescue
      p $!
    end

    begin
      user.age = 19
    rescue
      p $!
    end

    begin
      user.name = nil
    rescue
      p $!
    end

#* more detail checker do you need, you can use functional object here.
#  and Proc(lambda) run self's context
    class Game < Striuct
      member :monsters, ->monsters{[monsters - characters].empty?}
      member :characters, Array
    end
 
#* but, link to object is able to clash
#  use easy checker this case
    user.strict? #=> true
    user.address.clear
    user.strict? #=> false

#* procedure for cast case
    class User2 < Striuct.new
      member :age, /\A\d+\z/, Numeric do |arg|
        Integer arg
      end
    end
    
    user2 = User2.new
    user2.age = 9 #=> 9(Fixnum)
    user2.age = 10.1 #=> 10(Fixnum)
    user2.age = '10' #=> 10(Fixnum)

#* use default value
    class User3 < Striuct.new
      member  :lank, Fixnum
      default :lank, 3
      member  :name
    end
    
    user3 = User3.new
    user3.lank #=> 3
    
# Standard Struct always define "nil is default". ...realy?
   user3.name  #=> nil
   user3.assign? :name #=> false
   user3.name = nil
   user3.assign? :name #=> true

#* and keeping Struct's good interface
    Sth1 = Striuct.new :id, :last_name, :family_name, :address, :age

    Sth2 = Striuct.new do
      def m
      end
    end