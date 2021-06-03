# frozen_string_literal: true

class Striuct
  module InstanceMethods
    # @group Compare with other

    # @return [Boolean]
    def ==(other)
      other.instance_of?(self.class) &&
        each_pair.all? { |autonym, val| other._get(autonym) == val }
    end

    alias_method :===, :==

    def eql?(other)
      other.instance_of?(self.class) && other._db.eql?(@db)
    end

    # @return [Integer]
    def hash
      @db.hash
    end

    protected

    def _db
      @db
    end

    # @endgroup
  end; end
