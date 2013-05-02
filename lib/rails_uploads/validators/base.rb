module RailsUploads
  module Validators
    class Base < ActiveModel::EachValidator
      
      protected
      
      def add_error(record, attribute, type, options={})
        record.errors[attribute] << (options[:message] || I18n.t(type, options))        
      end
      
    end
  end
end
