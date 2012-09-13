striuct
=======

[![Build Status](https://secure.travis-ci.org/kachick/striuct.png)](http://travis-ci.org/kachick/striuct)

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
* More flendly API for Hash

### Onepoint

* Base API looks like Struct
* Pure Ruby :)

Usage
-----

### Overview - Case 1

```ruby
require 'striuct'

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
  member :bar, Numeric,                       # First validation under Numeric
               inference: true                # And use inference Validation
  member :with_adjuster, Integer,
                         &->v{Integer v}      # Use adjuster before a setter
end

foo = Foo.new

# nil <-> unaasigned
foo.foo                  #=> nil
foo.assign?(:foo)        #=> false
foo.foo = nil
foo.assign?(:foo)        #=> true

# Lock to a member
foo.lock(:foo)
foo.foo = nil            #=> error

# Inference Validation
foo.bar = 1.2            #=> pass             # memorize 1.2's class is Float
foo.bar = 1              #=> error            # 1 is not Float

# With adjuster
foo.with_adjuster = '5'
foo.with_adjuster        #=> 5                # Casted via adjuster
```

### How to build a flexible condition

* That from validation library.  
  See the [validation-API](http://kachick.github.com/validation/yard/frames.html)

Requirements
-------------

* [Ruby 1.9.2 or later](http://travis-ci.org/#!/kachick/striuct)
* [validation](https://github.com/kachick/validation) - 0.0.3
* [keyvalidatable](https://github.com/kachick/keyvalidatable) - 0.0.3

Install
-------

```bash
$ gem install striuct
```

Link
----

* [code](https://github.com/kachick/striuct)
* [API](http://kachick.github.com/striuct/yard/frames.html)
* [issues](https://github.com/kachick/striuct/issues)
* [CI](http://travis-ci.org/#!/kachick/striuct)
* [gem](https://rubygems.org/gems/striuct)

License
--------

The MIT X11 License  
Copyright (c) 2011 Kenichi Kamiya  
See the file LICENSE for further details.

