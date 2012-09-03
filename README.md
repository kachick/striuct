striuct
=======

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
* Hndling between nil <-> unassigned
* More flendly API for Hash

### Onepoint

* Base API looks like Struct
* Pure Ruby :)

Usage
-----

### Overview

```ruby
require 'striuct'

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
john[:name]              #=> 'john' 
john.name = ''           #=> Exception        # Validate with setter
john.id                  #=> 1
ken = User[name: 'ken']                       # Construct from hash
ken.id                   #=> 2
```

### More Examples

#### Basics

example/*

Requirements
-------------

* Ruby 1.9.2 or later [MRI/YARV, Rubinius](http://travis-ci.org/#!/kachick/striuct)
* validation - 0.0.3
* keyvalidatable - 0.0.2

Install
-------

```shell
$ gem install striuct
```

Link
----

* [code](https://github.com/kachick/striuct)
* [API](http://kachick.github.com/docs/striuct/api/frames.html)
* [issues](https://github.com/kachick/striuct/issues)
* [CI](http://travis-ci.org/#!/kachick/striuct)
* [gem](https://rubygems.org/gems/striuct)
* [gem+](http://metagem.info/gems/striuct)

License
--------

The MIT X License  
Copyright (c) 2011 Kenichi Kamiya  
See the file LICENSE for further details.

