class Striuct; module ClassMethods

  module HashDeepDupulicatable

    # @return [Hash]
    def deep_dup
      dup.tap {|h|
        each_pair do |key, value|
          h[key] = value.dup
        end
        h.extend HashDeepDupulicatable
      }
    end

  end

  if respond_to? :private_constant
    private_constant :HashDeepDupulicatable
  end

end; end
