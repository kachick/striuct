require 'keyvalidatable'

class Striuct; module InstanceMethods

  extend Forwardable
  include KeyValidatable

  KeyValidatable.instance_methods.each do |feature|
    if specific_feature = feature.to_s.sub!('members'){'autonyms'}
      def_delegator :self, feature, specific_feature.to_sym
    end
  end

end; end
