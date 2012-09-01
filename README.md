striuct
######=

{<img src="https://secure.travis-ci.org/kachick/striuct.png" />}[http://travis-ci.org/kachick/striuct]

Description
-----------

Struct++

Features
--------

### Strict

* Base API looks like Struct
* Easy and Flexible Validations
* Prevent to conflict member names

### Useful

* Hook just before setters
* Default value
* Member aliasing
* Inheritable

### Onepoint

* Pure Ruby :)

Usage
-----

### Setup

```ruby
require 'striuct'
```

### Overview

#### Define member & Classic validation

```ruby
Person = Striuct.define do
  member :name, String
end
```

#### Inferitable & Flexible validation & Member aliasing

```ruby
class User < Person
  member :identifier, AND(Integer, 1..10)
  alias_member :id, :identifier
end

user = User.new
user.members      #=> [:name, :identifier]
user.name = :Ken  #=> exception / in `name=': :Ken is deficient for name in User
user.name = 'Ken' #=> pass
user[:id] = 2     #=> pass
user[:id] = 11    #=> exception / in `[:id(identifier)]=': 11 is deficient for identifier in User
```

### More Examples

#### Basics

examples/*

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
* [issues](https://github.com/kachick/striuct/issues)
* [CI](http://travis-ci.org/#!/kachick/striuct)
* [gem](https://rubygems.org/gems/striuct)
* [gem+](http://metagem.info/gems/striuct)

License
--------

The MIT X License  
Copyright (c) 2011 Kenichi Kamiya  
See the file LICENSE for further details.

