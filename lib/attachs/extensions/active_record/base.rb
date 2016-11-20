module Attachs
  module Extensions
    module ActiveRecord
      module Base
        extend ActiveSupport::Concern

        module ClassMethods

          def has_attachment(*args)
            builder = Builder.new(self)
            builder.define *args
          end

          def has_attachments(*args)
            options = args.extract_options!
            options[:multiple] = true
            has_attachment *args.append(options)
          end

        end
      end
    end
  end
end
