module Attachs
  module Extensions
    module ActiveRecord
      module Validations
        extend ActiveSupport::Concern

        class AttachmentValidator < ActiveModel::EachValidator

          def validate_each(record, attribute, attachment_or_collection)
            case attachment_or_collection
            when Collection
              attachment_or_collection.each do |attachment|
                validate_one record, attribute, attachment
              end
            when Attachment
              validate_one record, attribute, attachment_or_collection
            end
          end

        end
      end
    end
  end
end
