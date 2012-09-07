class Striuct; module ClassMethods

  # @group To Ruby's Struct Class

  # @return [Class]
  def to_struct_class
    raise 'No defined members' if autonyms.empty?

    struct_cls = ::Struct.new(*autonyms)
    return struct_cls unless name

    const_suffix = name.slice(/[^:]+\z/).to_sym
    if ::Striuct::Structs.const_defined?(const_suffix, false) && 
       (already_cls = ::Striuct::Structs.const_get(const_suffix, false)).members == autonyms
       raise unless already_cls.superclass.equal? Struct
       already_cls
    else
      ::Striuct::Structs.const_set const_suffix, struct_cls
    end
  end

  # @endgroup

end; end