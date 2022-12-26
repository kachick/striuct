# striuct

![Build Status](https://github.com/kachick/striuct/actions/workflows/test_behaviors.yml/badge.svg?branch=main)
[![Gem Version](https://badge.fury.io/rb/striuct.svg)](http://badge.fury.io/rb/striuct)

Struct++

## Usage

Require Ruby 2.7 or later

Add this line to your `Gemfile`

```ruby
gem 'striuct', '~> 0.9.0'
```

Then add below code into your Ruby code

```ruby
require 'striuct'
```

### Overview

#### Case 1

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

#### Case 2

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

#### Case 3

```ruby
class UseMustOption < Striuct
  member :foo, Integer, must: true
end

UseMustOption.new #=> InvalidOperationError "`foo` require a value under `must` option "
```

## Features

### Strict

* Easy and Flexible Validations
  * Basically use `#===` for the validation
  * The pattern builder DSL is just using [eqq](https://github.com/kachick/eqq)
  * When passed the Proc, it will be evaluated in the instance context
* Prevent to conflict member names
* Lock setters for each member

### Useful

* Hook just before setters
* Default value
* Member aliasing
* Inheritable
* Handling between nil <-> unassigned
* Similar API for Hash

### Finally

* Base API looks like Struct
* Pure Ruby :)

## Link

* [Repository](https://github.com/kachick/striuct)
* [API documents](https://kachick.github.io/striuct/)
