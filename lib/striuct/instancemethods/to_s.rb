# frozen_string_literal: true

class Striuct
  module InstanceMethods
    # @group To Strings

    # @return [String]
    def inspect
      "#<struct' #{self.class}".tap { |s|
        each_pair do |autonym, value|
          suffix = (with_default?(autonym) && default?(autonym)) ? '/default' : nil
          label_valid = valid?(autonym) ? nil : :invalid
          label_lock = locked?(autonym) ? :locked : nil
          label_must = must?(autonym) ? :must : nil
          labels = [label_valid, label_lock, label_must].select { |elm| elm }

          s << " #{autonym}=#{value.inspect}#{suffix}"
          unless labels.empty?
            s << '('
            s << labels.join(', ')
            s << ')'
          end
          s << ','
        end

        s.chop!
        s << '>'
      }
    end

    # @return [String]
    def to_s
      "#<struct' #{self.class}".tap { |s|
        each_pair do |autonym, value|
          s << " #{autonym}=#{value.inspect},"
        end

        s.chop!
        s << '>'
      }
    end

    # @endgroup
  end
end
