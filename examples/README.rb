$VERBOSE = true

require '../lib/striuct'

Person = Striuct.define do
  member :name, String
end

class User < Person
  member :identifier, AND(Integer, 1..10)
  alias_member :id, :identifier
end

user = User.new
p user.members      #=> [:name, :id]
#~ p user.name = :Ken  #=> error
p user.name   = 'Ken' #=> pass
p user[:id]   = 2     #=> pass
p user[:id]   = 11    #=> error