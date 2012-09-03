class Striuct; module ClassMethods

  # @group To Ruby's Struct Class

  # @return [Class]
  def to_struct_class
    raise 'No defined members' if autonyms.empty?

    struct_klass = Struct.new(*names)
  
    if name
      tail_name = name.slice(/[^:]+\z/)
      if ::Striuct::Structs.const_defined?(tail_name) && 
          ((already = ::Striuct::Structs.const_get(tail_name)).members == members)
          already
      else
        ::Striuct::Structs.const_set tail_name, struct_klass
      end
    else
      struct_klass
    end
  end

  # @endgroup

end; end