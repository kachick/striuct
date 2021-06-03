# frozen_string_literal: true

class Striuct
  module ClassMethods
    # @group Member Conflict Management

    # @return [Hash] Symbol => Fixnum
    NAMING_RISKS = {
      conflict: 10,
      no_identifier: 9,
      bad_manners: 5,
      no_ascii: 3,
      strict: 0
    }.freeze

    # @return [Hash] Symbol => Hash
    CONFLICT_MANAGEMENT_LEVELS = {
      struct: { error: 99, warn: 99 },
      warning: { error: 99, warn: 5 },
      error: { error: 9, warn: 5 },
      prevent: { error:  5, warn:  1 },
      nervous: { error:  1, warn:  1 }
    }.each(&:freeze).freeze

    # @return [Symbol]
    DEFAULT_CONFLICT_MANAGEMENT_LEVEL = :prevent

    # @param [Object] name
    # accpeptable the name into own member, under protect level of runtime
    def cname?(name)
      _check_safety_naming(name.to_sym) { |r| r }
    rescue Exception
      false
    end

    attr_reader :conflict_management_level

    private

    # @param [Symbol, String, #to_sym] level
    # @return [Symbol] level
    # change level of management conflict member names
    def set_conflict_management_level(level)
      level = level.to_sym
      raise NameError unless CONFLICT_MANAGEMENT_LEVELS.key?(level)

      @conflict_management_level = level
    end

    # @param [Symbol, String, #to_sym] level
    # @see [#set_conflict_management_level]
    # @yieldreturn [self]
    # @return [void]
    # @raise [ArgumentError] if no block given
    # temp scope of a conflict_management_level
    def conflict_management(level=DEFAULT_CONFLICT_MANAGEMENT_LEVEL)
      before = @conflict_management_level
      set_conflict_management_level(level)

      yield
    ensure
      @conflict_management_level = before
      self
    end

    # @param [Symbol] name
    # @return [void]
    # @yieldreturn [Boolean]
    def _check_safety_naming(name)
      estimation = _estimate_naming(name)
      risk    = NAMING_RISKS.fetch(estimation)
      plevels = CONFLICT_MANAGEMENT_LEVELS.fetch(@conflict_management_level)
      caution = "undesirable naming '#{name}', because #{estimation}"

      r = (
        case
        when risk >= plevels.fetch(:error)
          raise NameError, caution unless block_given?

          false
        when risk >= plevels.fetch(:warn)
          warn(caution) unless block_given?
          false
        else
          true
        end
      )

      yield r if block_given?
    end

    # @param [Symbol] name
    # @return [Symbol]
    def _estimate_naming(name)
      if (instance_methods + private_instance_methods).include?(name)
        return :conflict
      end

      return :no_ascii unless name.encoding.equal?(Encoding::ASCII)

      case name
      when /\W/, /\A[^a-zA-Z_]/, :''
        :no_identifier
      when /\Aeach/, /\A__[^_]*__\z/, /\A_[^_]*\z/, /[!?]\z/, /\Ato_/
        :bad_manners
      when /\A[a-zA-Z_]\w*\z/
        :strict
      else
        raise 'must not happen'
      end
    end

    # @endgroup
  end; end
