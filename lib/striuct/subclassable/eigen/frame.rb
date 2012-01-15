class Striuct; module Subclassable

# @author Kenichi Kamiya
module Eigen

  class << self
    private
    
    def extended(klass)
      klass.class_eval do
        @names, @conditions, @flavors, @defaults = [], {}, {}, {}
        @inferences, @aliases, @protect_level = {}, {}, :prevent
      end
    end
  end
  
  NAMING_RISKS = {
    conflict:      10,
    no_identifier:  9,
    bad_manners:    5,
    no_ascii:       3,
    strict:         0 
  }.freeze

  PROTECT_LEVELS = {
    struct:      {error: 99, warn: 99},
    warning:     {error: 99, warn:  5},
    error:       {error:  9, warn:  5},
    prevent:     {error:  5, warn:  1},
    nervous:     {error:  1, warn:  1}
  }.each(&:freeze).freeze

  INFERENCE = Object.new.freeze

  BOOLEAN = ->v{[true, false].include?(v)}

  STRINGABLE = ->v{
    [String, Symbol].any?{|klass|v.kind_of?(klass)} ||
    v.respond_to?(:to_str)
  }
  
  if respond_to? :private_constant
    private_constant :INFERENCE, :BOOLEAN, :STRINGABLE
  end

end

end; end

require_relative 'basic'
require_relative 'constructor'
require_relative 'safety'
require_relative 'handy'
require_relative 'macro'
require_relative 'conditions'
require_relative 'inner'