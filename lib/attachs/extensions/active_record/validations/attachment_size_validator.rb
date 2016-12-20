module Attachs
  module Extensions
    module ActiveRecord
      module Validations
        extend ActiveSupport::Concern

        class AttachmentSizeValidator < AttachmentValidator
          CHECKS = { less_than: :<, less_than_or_equal_to: :<=, greater_than: :>, greater_than_or_equal_to: :>= }

          def initialize(options)
            if range = (options[:in] || options[:within])
              options[:less_than_or_equal_to] = range.max
              options[:greater_than_or_equal_to] = range.min
            end
            super
          end

          def validate_attachment(record, attachment)
            unless attachment.blank?
              CHECKS.each do |name, operator|
                if options.has_key?(name)
                  other = options[name]
                  case other
                  when Symbol
                    other = record.send(other)
                  when Proc
                    other = other.call(record)
                  end
                  unless attachment.size.send(operator, other)
                    attachment.errors.add :value, name, count: humanize_size(other)
                  end
                end
              end
            end
          end

          private

          def humanize_size(size)
            ActiveSupport::NumberHelper.number_to_human_size size
          end

        end
        module ClassMethods

          def validates_attachment_size_of(*attributes)
            validates_with AttachmentSizeValidator, _merge_attributes(attributes)
          end

        end
      end
    end
  end
end
