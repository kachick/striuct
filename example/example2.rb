# frozen_string_literal: true

require_relative '../lib/striuct'

User = Striuct.define do  # other way "class User < Striuct.new"
  member :first_name, /\w+/ # look like case syntax in Ruby
  member :lank, AND(Integer, 1..10) # easy build multiple validation
  default :lank, 3        # set a normal default value
  member :registered, Time # look like type variable
  default :registered, &->{Time.now} # evaluate with construction
  p members #=> [first_name, lank, registered]
end

class MyUser < User
  p members #=> [first_name, lank, registered]
  member :foo # no validation, just an accessor
  p members #=> [first_name, lank, registered, :foo]
end

user = MyUser.new
p user
