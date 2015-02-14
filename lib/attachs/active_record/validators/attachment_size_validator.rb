module Attachs
  module ActiveRecord
    module Validators
      class AttachmentSizeValidator < ActiveModel::EachValidator
        include ActionView::Helpers::NumberHelper

        def validate_each(record, attribute, value)
          if value.exists?
            if options.has_key? :in
              if options[:in].exclude? value.size
                record.errors.add(
                  attribute,
                  :attachment_size_in,
                  min: number_to_human_size(options[:in].begin),
                  max: number_to_human_size(options[:in].end)
                )
              end
            else
              if options.has_key? :less_than and value.size > options[:less_than]
                record.errors.add(
                  attribute,
                  :attachment_size_less_than,
                  count: number_to_human_size(options[:less_than])
                )
              end
              if options.has_key? :greater_than and value.size < options[:greater_than]
                record.errors.add(
                  attribute,
                  :attachment_size_greater_than,
                  count: number_to_human_size(options[:greater_than])
                )
              end
            end
          end
        end

      end
      module ClassMethods

        def validates_attachment_size_of(*attr_names)
          validates_with AttachmentSizeValidator, _merge_attributes(attr_names)
        end

      end
    end
  end
end
