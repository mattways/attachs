module Attachs
  module Extensions
    module ActiveRecord
      module Validations
        extend ActiveSupport::Concern

        class AttachmentPresenceValidator < AttachmentValidator

          def validate_one(record, attribute, attachment)
            unless attachment.blank?
              record.errors.add attribute, :invalid
              attachment.errors.add :base, :blank
            end
          end

        end
        module ClassMethods

          def validates_attachment_presence_of(*attr_names)
            validates_with AttachmentPresenceValidator, _merge_attributes(attr_names)
          end

        end
      end
    end
  end
end
