# frozen_string_literal: true

class Striuct
  module ClassMethods
    # @group Macro for Member Definition

    ANYTHING = Eqq.ANYTHING()

    # @return [Class]

    private

    # @param [Symbol, String, #to_sym] autonym
    # @param [#===, Proc, Method] pattern
    # @param [Proc] default_proc
    # @param [Boolean] must
    # @param [Boolean] writer_validation
    # @param [Boolean] reader_validation
    # @return [void]
    def add_member(autonym, pattern=ANYTHING, default_value: nil, default_proc: nil, must: false, writer_validation: true, reader_validation: false, &adjuster)
      _check_frozen
      _check_closed

      raise ArgumentError if !default_value.nil? && default_proc

      autonym = autonym.to_sym # First definition for an autonym

      raise ArgumentError, %Q!already exist name "#{autonym}"! if member?(autonym)

      _check_safety_naming(autonym)
      _add_autonym(autonym)

      _attributes_for(autonym).safety_setter = writer_validation
      _attributes_for(autonym).safety_getter = reader_validation

      if must
        _attributes_for(autonym).must = true
      end

      _def_getter(autonym)
      _def_setter(autonym, pattern, &adjuster)

      case
      when !default_value.nil?
        set_default_value(autonym, default_value)
      when default_proc
        set_default_value(autonym, &default_proc)
      end

      nil
    end

    alias_method :member, :add_member

    # @param [Symbol, String, #to_sym] autonym
    # @param [Symbol, String, #to_sym] autonyms
    # @return [nil]
    def add_members(autonym, *autonyms)
      _check_frozen
      _check_closed

      [autonym, *autonyms].each { |name| add_member(name) }
      nil
    end

    # @param [Symbol, String, #to_sym] aliased
    # @param [Symbol, String, #to_sym] autonym
    # @return [nil]
    def alias_member(aliased, autonym)
      _check_frozen
      _check_closed
      autonym = autonym_for_member(autonym)
      aliased = aliased.to_sym
      raise ArgumentError, %Q!already exist name "#{aliased}"! if member?(aliased)

      _check_safety_naming(aliased)

      alias_method(aliased, autonym)
      alias_method(:"#{aliased}=", :"#{autonym}=")
      @aliases[aliased] = autonym
      nil
    end

    # @param [Symbol, String, #to_sym] name
    # @return [nil]
    def set_default_value(name, value=nil, &block)
      _check_frozen
      _check_closed
      autonym = autonym_for_member(name)
      raise "already settled default value for #{name}" if with_default?(autonym)

      if block
        unless value.nil?
          raise ArgumentError, 'can not use default-value with default-proc'
        end

        _attributes_for(autonym).set_default(block, :lazy)
      else
        _attributes_for(autonym).set_default(value, :value)
      end

      nil
    end

    alias_method :default, :set_default_value

    # @endgroup
  end
end
