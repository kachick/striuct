class Striuct

  # Useful Flavor Builders
  # @author Kenichi Kamiya
  module Flavors
    module_function

    # @param [Object] flavor
    def adjustable?(flavor)
      case flavor
      when Proc
        flavor.arity == 1
      else
        if flavor.respond_to?(:to_proc)
          flavor.to_proc.arity == 1
        else
          false
        end
      end
    end
    
    alias_method :flavorable?, :adjustable?
    
    # @return [lambda]
    def WHEN(condition, flavor)
      raise TypeError, 'wrong object for condition' unless conditionable? condition
      raise TypeError, 'wrong object for flavor' unless adjustable? flavor
      
      ->v{pass?(v, condition) ? flavor.call(v) : v}
    end
    
    # @return [lambda]
    def REDUCE(flavor1, flavor2, *flavors)
      flavors = [flavor1, flavor2, *flavors]

      unless flavors.all?{|f|adjustable? f}
        raise TypeError, 'wrong object for flavor'
      end

      ->v{
        flavors.reduce(v){|ret, flavor|flavor.call ret}
      }
    end
    
    alias_method :FLAVORS, :REDUCE
    alias_method :INJECT, :REDUCE

    # @return [lambda]
    def PARSE(parser)
      if !::Integer.equal?(parser) and !parser.respond_to?(:parse)
        raise TypeError, 'wrong object for parser'
      end
      
      ->v{
        if ::Integer.equal? parser
          ::Kernel.Integer v
        else
          parser.parse(
            case v
            when String
              v
            when ->_{v.respond_to? :to_str}
              v.to_str
            when ->_{v.respond_to? :read}
              v.read            
            else
              raise TypeError, 'wrong object for parsing source'
            end
          )
        end
      }
    end
  end

end
