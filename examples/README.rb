$VERBOSE = true

require '../lib/striuct'

class Person < Striuct
  member :fullname, AND(String, /\A.+\z/)     # Flexible Validation
  alias_member :name, :fullname               # Use other name
end

class User < Person                           # Inheritable
  member :id, Integer,                        # Looks typed validation
              default_proc: ->{User.next_id}  # With default value

  def self.next_id
    @id ||= 0
    @id += 1
  end
end

john = User.new 'john'
p john[:name]      #=> 'john' 
#~ p john.name = :symbol  #=> error
p john.id          #=> 1
ken = User[name: 'ken']                       # Construct from hash
p ken.id           #=> 2