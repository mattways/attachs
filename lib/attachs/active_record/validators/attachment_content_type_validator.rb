module Attachs
  module ActiveRecord
    module Validators
      class AttachmentContentTypeValidator < ActiveModel::EachValidator

        def validate_each(record, attribute, value)
          if value.exists?
            if options[:in].exclude? value.content_type
              record.errors.add attribute, :attachment_content_type, types: options[:in].to_sentence
            end
          end
        end

      end
      module ClassMethods

        def validates_attachment_content_type_of(*attr_names)
          validates_with AttachmentContentTypeValidator, _merge_attributes(attr_names)
        end

      end
    end
  end
end
