module Rails
  module Uploads
    module Validators
      class Base < ActiveModel::EachValidator
        
        protected
      
        def has_default?(record, attribute)
          options = record.class.instance_variable_get('@attachments')[attribute]
          options.has_key?(:default)
        end
        
        def add_error(record, attribute, type, options={})
          record.errors[attribute] << (options[:message] || I18n.t(type, options))        
        end
        
      end
    end
  end
end
