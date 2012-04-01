$VERBOSE = true

require '../lib/striuct'

Person = Striuct.define do
  member :name, AND(String, /\A\w+( \w+)?\z/)
end

class User < Person
  member :id, AND(Integer, 1..99999)
end

user = User.new
p user.members      #=> [:name, :id]
p user.name = :Ken  #=> error
p user.name = ''    #=> error
p user.name = 'Ken' #=> pass
