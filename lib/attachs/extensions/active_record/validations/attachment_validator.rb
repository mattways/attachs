module Attachs
  module Extensions
    module ActiveRecord
      module Validations
        extend ActiveSupport::Concern

        class AttachmentValidator < ActiveModel::EachValidator

          def validate_each(record, attribute, attachment_or_collection)
            if record.class.reflections[attribute.to_s].macro == :has_many
              attachment_or_collection.each do |attachment|
                validate_attachment record, attachment
                propagate_error record, attribute, attachment
              end
            else
              validate_attachment record, attachment_or_collection
              propagate_error record, attribute, attachment_or_collection
            end
          end

          private

          def propagate_error(record, attribute, attachment)
            if attachment.errors.any?
              record.errors.add attribute, :invalid
            end
          end

        end
      end
    end
  end
end
