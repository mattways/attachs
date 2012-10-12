module RailsUploads
  module Validators
    class Base < ActiveModel::EachValidator
      
      protected
      
      def add_error(record, attribute, type, options={})
        record.errors[attribute] << (options[:message] || I18n.t(type, options))        
      end
      
      def iterate_attachments(record, attribute, value)
        multiple = record.class.instance_variable_get('@attachments')[attribute][:multiple]
        (multiple ? value : [value]).each {|v| yield v } if value    
      end
      
    end
  end
end