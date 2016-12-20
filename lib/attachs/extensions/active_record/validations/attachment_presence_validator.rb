module Attachs
  module Extensions
    module ActiveRecord
      module Validations
        extend ActiveSupport::Concern

        class AttachmentPresenceValidator < AttachmentValidator

          def validate_attachment(record, attachment)
            if attachment.blank?
              attachment.errors.add :value, :blank
            end
          end

        end
        module ClassMethods

          def validates_attachment_presence_of(*attributes)
            validates_with AttachmentPresenceValidator, _merge_attributes(attributes)
          end

        end
      end
    end
  end
end
