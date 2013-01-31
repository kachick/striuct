$VERBOSE = true

require_relative '../lib/striuct'

class Person < Striuct
  member :fullname, AND(String, /\A.+\z/)     # Flexible Validation
  alias_member :name, :fullname               # Use other name
end

class User < Person                           # Inheritable
  member :id, Integer,                        # Looks typed validation
              default_proc: ->{User.next_id}  # With default value

  @id = 0
  def self.next_id
    @id += 1
  end
end

john = User.new 'john'
p john[:name]      #=> 'john' 
#~ p john.name = ''  #=> error
p john.id          #=> 1
ken = User[name: 'ken']                       # Construct from hash
p ken.id           #=> 2

class Foo < Striuct
  member :foo
  member :bar, Numeric,
               inference: true
  member :with_adjuster, Integer,
                         &->v{Integer v}
end

foo = Foo.new
p foo.foo           #=> nil
p foo.assign?(:foo) #=> false
foo.foo = nil
p foo.assign?(:foo) #=> true
foo.lock(:foo)
#~ foo.foo = nil       #=> error
foo.bar = 1.2
#~ foo.bar = 1          #=> error

foo.with_adjuster = '5'
p foo.with_adjuster