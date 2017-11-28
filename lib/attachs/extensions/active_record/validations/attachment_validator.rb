module Attachs
  module Extensions
    module ActiveRecord
      module Validations
        extend ActiveSupport::Concern

        class AttachmentValidator < ActiveModel::EachValidator

          def validate_each(attachable, attribute, attachment_or_collection)
            if attachable.class.reflections[attribute.to_s].macro == :has_many
              attachment_or_collection.each do |attachment|
                if attachment.validable?
                  validate_attachment attachable, attachment
                  propagate_error attachable, attribute, attachment
                end
              end
            else
              if attachment_or_collection.validable?
                validate_attachment attachable, attachment_or_collection
                propagate_error attachable, attribute, attachment_or_collection
              end
            end
          end

          private

          def propagate_error(attachable, attribute, attachment)
            if attachment.errors.any?
              attachable.errors.add attribute, :invalid
            end
          end

        end
      end
    end
  end
end
