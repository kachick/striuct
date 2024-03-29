# frozen_string_literal: true

class Striuct
  module InstanceMethods
    # @group Setter

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    # @return value
    def []=(key, value)
      autonym = autonym_for_key(key)
      _set(autonym, value)
    rescue InvalidWritingError
      $!.set_backtrace(
        ["#{$!.backtrace[-1].sub(/[^:]+\z/) { '' }}in `[#{key.inspect}(#{autonym})]=': #{$!.message}", $!.backtrace[-1]]
      )

      raise
    end

    alias_method :assign, :[]=

    private

    # @param [Symbol] autonym - MUST already converted to native autonym
    # @return value
    def _set(autonym, value)
      _check_frozen
      _check_locked(autonym)

      if with_adjuster?(autonym)
        begin
          value = instance_exec(value, &adjuster_for(autonym))
        rescue Exception
          raise InvalidAdjustingError
        end
      end

      if with_safety_setter?(autonym) && !accept?(autonym, value)
        raise InvalidWritingError,
              "#{value.inspect} is deficient for #{autonym} in #{self.class}"
      end

      @db[autonym] = value
    rescue InvalidValueError
      # @note Why caller with range instead of the index? See https://github.com/rubocop/rubocop/pull/4078
      unless caller(2..2).first.slice(/([^:]+)\z/).include?('in []=')
        $!.backtrace.delete_if { |s| /#{Regexp.escape(File.dirname(__FILE__))}/ =~ s }
        $!.backtrace.first.sub!(/([^:]+)\z/) { "in `#{autonym}='" }
      end

      raise
    end

    # @endgroup
  end
end
