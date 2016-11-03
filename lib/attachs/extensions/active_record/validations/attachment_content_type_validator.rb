module Attachs
  module Extensions
    module ActiveRecord
      module Validations
        extend ActiveSupport::Concern

        class AttachmentContentTypeValidator < AttachmentValidator

          def validate_one(record, attribute, attachment)
            unless attachment.blank?
              if options.has_key?(:with)
                if options[:with] !~ attachment.content_type
                  record.errors.add attribute, :invalid
                  attachment.errors.add :content_type, :not_allowed
                end
              elsif options.has_key?(:in) || options.has_key?(:within)
                list = (options[:in] || options[:within])
                if list.exclude?(attachment.content_type)
                  record.errors.add attribute, :invalid
                  attachment.errors.add :content_type, :not_listed, list: list.to_sentence
                end
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
end
