require_relative 'containable/classutil'
require_relative 'containable/classmethods'
require_relative 'containable/specificcontainer'
require_relative 'containable/singleton_class'

class Striuct

  module Containable

    extend ClassUtil
    include Enumerable

  end

end

require_relative 'containable/basic'
require_relative 'containable/safety'
require_relative 'containable/handy'
require_relative 'containable/hashlike'
require_relative 'containable/inner'