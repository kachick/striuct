require 'keyvalidatable'

class Striuct; module InstanceMethods

  include KeyValidatable

  KeyValidatable.instance_methods.each do |feature|
    if specific_feature = feature.to_s.sub!('members'){'autonyms'}
      alias_method specific_feature.to_sym, feature
    end
  end

end; end
