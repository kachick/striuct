striuct
=======

![Build Status](https://github.com/kachick/striuct/actions/workflows/test_behaviors.yml/badge.svg?branch=main)
[![Gem Version](https://badge.fury.io/rb/striuct.png)](http://badge.fury.io/rb/striuct)

Description
-----------

Struct++

Features
--------

### Strict

* Easy and Flexible Validations
* Prevent to conflict member names
* Lock setters for each member

### Useful

* Hook just before setters
* Default value
* Member aliasing
* Inheritable
* Handling between nil <-> unassigned
* Similar API for Hash

### Onepoint

* Base API looks like Struct
* Pure Ruby :)

Usage
-----

Require Ruby 2.6 or later

Add this line to your `Gemfile`

```ruby
gem 'striuct', '>= 0.7.0', '< 0.8.0'
```

### Overview - Case 1

```ruby
require 'striuct'

class Person < Striuct
  member :full_name, AND(String, /\A.+\z/)     # Flexible Validation
  alias_member :name, :full_name               # Use other name
end

# Inheritable
class User < Person
  member :id, Integer,                        # Looks typed validation
              default_proc: ->{User.next_id}  # With default value

  @id = 0
  def self.next_id
    @id += 1
  end
end

john = User.new 'john'
john[:name]              #=> 'john'
john.name = ''           #=> Exception        # Validate with setter
john.id                  #=> 1
ken = User[name: 'ken']                       # Construct from hash
ken.id                   #=> 2
```

### Overview - Case 2

```ruby
class Foo < Striuct
  member :foo
  member :bar, Numeric
  member :with_adjuster, Integer,
                         &->v{Integer v}      # Use adjuster before a setter
end

foo = Foo.new

# nil <-> unassigned
foo.foo                  #=> nil
foo.assigned?(:foo)      #=> false
foo.foo = nil
foo.assigned?(:foo)      #=> true

# Lock to a member
foo.lock(:foo)
foo.foo = nil            #=> error

foo.bar = 1.2            #=> pass             # memorize 1.2's class is Float
foo.bar = 1              #=> error            # 1 is not Float

# With adjuster
foo.with_adjuster = '5'
foo.with_adjuster        #=> 5                # Casted via adjuster
```

### Overview - Case 3

```ruby
class UseMustOption < Striuct
  member :foo, Integer, must: true
end

UseMustOption.new #=> InvalidOperationError "`foo` require a value under `must` option "
```

Link
----

* [Repository](https://github.com/kachick/striuct)
* [API documents](https://kachick.github.io/striuct/)
