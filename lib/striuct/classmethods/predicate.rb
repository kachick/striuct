# frozen_string_literal: true

class Striuct
  module ClassMethods
    # @group Basic Predicate

    # @param [Symbol, String, #to_sym] name
    def has_autonym?(name)
      name = name.to_sym
    rescue NoMethodError
      false
    else
      @autonyms.include?(name)
    end

    alias_method :autonym?, :has_autonym?

    # @param [Symbol, String, #to_sym] als
    def has_alias?(als)
      als = als.to_sym
    rescue NoMethodError
      false
    else
      @aliases.key?(als)
    end

    alias_method :alias?, :has_alias?
    alias_method :aliased?, :has_alias? # obsolete

    # @param [Symbol, String, #to_sym] name
    def has_member?(name)
      autonym_for_member(name)
    rescue Exception
      false
    else
      true
    end

    alias_method :member?, :has_member?

    # @param [Integer, #to_int] index
    def has_index?(index)
      @autonyms.fetch(index)
    rescue Exception
      false
    else
      true
    end

    alias_method :index?, :has_index?

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    def has_key?(key)
      has_member?(key) || has_index?(key)
    end

    alias_method :key?, :has_key?

    # @param [Symbol, String, #to_sym] autonym
    def with_aliases?(autonym)
      autonym = autonym.to_sym
    rescue NoMethodError
      false
    else
      @aliases.value?(autonym)
    end

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    def with_default?(key)
      autonym = autonym_for_key(key)
    rescue Exception
      false
    else
      _attributes_for(autonym).with_default?
    end

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    def with_condition?(key)
      autonym = autonym_for_key(key)
    rescue Exception
      false
    else
      _attributes_for(autonym).with_condition?
    end

    alias_method :restrict?, :with_condition?

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    def with_must?(key)
      autonym = autonym_for_key(key)
    rescue Exception
      false
    else
      _attributes_for(autonym).with_must?
    end

    alias_method :must?, :with_must?

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    def with_safety_getter?(key)
      autonym = autonym_for_key(key)
    rescue Exception
      false
    else
      _attributes_for(autonym).with_safety_getter?
    end

    alias_method :with_safety_reader?, :with_safety_getter?

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    def with_safety_setter?(key)
      autonym = autonym_for_key(key)
    rescue Exception
      false
    else
      _attributes_for(autonym).with_safety_setter?
    end

    alias_method :with_safety_writer?, :with_safety_setter?

    # @param [Symbol, String, #to_sym, Integer, #to_int] key - name / index
    def with_adjuster?(key)
      autonym = autonym_for_key(key)
    rescue Exception
      false
    else
      _attributes_for(autonym).with_adjuster?
    end

    # @endgroup
  end; end
