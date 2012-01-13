#/usr/bin/ruby -w

require 'benchmark'
require_relative 'lib/striuct'

XStruct = Struct.new :any, :no_use1, :no_use2

XStriuct = Striuct.define do
  member :any
  member :int, Integer
  member :truthy, ->v{v}
end

xstruct = XStruct.new
xstriuct = XStriuct.new

TIMES = 100000
OBJ = 123

Benchmark.bm do |bm|
  bm.report 'Struct equal Noguard' do
    TIMES.times do
      xstruct.any = OBJ
    end
  end
  
  bm.report 'Striuct have no conditions' do
    TIMES.times do
      xstriuct.any = OBJ
    end
  end

  bm.report 'Striuct under class' do
    TIMES.times do
      xstriuct.int = OBJ
    end
  end
  
  bm.report 'Striuct under function' do
    TIMES.times do
      xstriuct.truthy = OBJ
    end
  end
end
