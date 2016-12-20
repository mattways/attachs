module Attachs
  module Extensions
    module ActiveRecord
      module Validations
        extend ActiveSupport::Concern

        class AttachmentContentTypeValidator < AttachmentValidator

          def validate_attachment(record, attachment)
            unless attachment.blank?
              if options.has_key?(:with)
                if options[:with] !~ attachment.content_type
                  attachment.errors.add :value, :not_allowed
                end
              elsif options.has_key?(:in) || options.has_key?(:within)
                list = (options[:in] || options[:within])
                if list.exclude?(attachment.content_type)
                  attachment.errors.add :value, :can_only_be, list: list.to_sentence
                end
              end
            end
          end

        end
        module ClassMethods

          def validates_attachment_content_type_of(*attributes)
            validates_with AttachmentContentTypeValidator, _merge_attributes(attributes)
          end

        end
      end
    end
  end
end
