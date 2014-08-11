module Attachs
  module ActiveRecord
    module Validators
      class AttachmentPresenceValidator < ActiveModel::EachValidator

        def validate_each(record, attribute, value)
          if value.blank?
            record.errors.add attribute, :attachment_presence
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
