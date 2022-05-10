# frozen_string_literal: true

class Striuct
  module ClassMethods
    # @group Adjuster

    # Adjuster Builders
    # Apply adjuster when passed pattern.
    # @param pattern [Proc, Method, #===]
    # @param adjuster [Proc, #to_proc]
    # @return [Proc]
    def WHEN(pattern, adjuster)
      unless Eqq.pattern?(pattern)
        raise ArgumentError, 'wrong object for pattern'
      end

      unless Striuct.adjustable?(adjuster)
        raise ArgumentError, 'wrong object for adjuster'
      end

      ->v { _valid?(pattern, v) ? adjuster.call(v) : v }
    end

    # Sequential apply all adjusters.
    # @param adjuster1 [Proc, #to_proc]
    # @param adjuster2 [Proc, #to_proc]
    # @param adjusters [Proc, #to_proc]
    # @return [Proc]
    def INJECT(adjuster1, adjuster2, *adjusters)
      adjusters = [adjuster1, adjuster2, *adjusters]

      unless adjusters.all? { |f| adjustable?(f) }
        raise ArgumentError, 'wrong object for adjuster'
      end

      ->v {
        adjusters.reduce(v) { |ret, adjuster| adjuster.call(ret) }
      }
    end

    # Accept any parser when that respond to parse method.
    # @param parser [#parse]
    # @return [Proc]
    def PARSE(parser)
      if !::Integer.equal?(parser) && !parser.respond_to?(:parse)
        raise ArgumentError, 'wrong object for parser'
      end

      ->v {
        if ::Integer.equal?(parser)
          ::Kernel.Integer(v)
        else
          parser.parse(
            case v
            when String
              v
            when ->_ { v.respond_to?(:to_str) }
              v.to_str
            when ->_ { v.respond_to?(:read) }
              v.read
            else
              raise TypeError, 'wrong object for parsing source'
            end
          )
        end
      }
    end

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    def adjuster_for(key)
      autonym = autonym_for_key(key)
      raise KeyError unless with_adjuster?(autonym)

      _attributes_for(autonym).adjuster
    end

    # @endgroup
  end
end
