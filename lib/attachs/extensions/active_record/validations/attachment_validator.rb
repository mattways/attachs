module Attachs
  module Extensions
    module ActiveRecord
      module Validations
        extend ActiveSupport::Concern

        class AttachmentValidator < ActiveModel::EachValidator

          def validate_each(record, record_attribute, attachment_or_collection)
            case attachment_or_collection
            when Collection
              attachment_or_collection.each do |attachment|
                validate_attachment record, attachment
                if attachment.errors.any?
                  record.errors.add record_attribute
                end
              end
            when Attachment
              validate_attachment record, attachment_or_collection
              if attachment_or_collection.errors.any?
                attachment_or_collection.errors.each do |attachment_attribute, message|
                  record.errors.add record_attribute, message
                end
              end
            end
          end

        end
      end
    end
  end
end
