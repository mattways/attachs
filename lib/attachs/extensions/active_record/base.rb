module Attachs
  module Extensions
    module ActiveRecord
      module Base
        extend ActiveSupport::Concern

        module ClassMethods

          def has_attachment(*args)
            builder = Builder.new(self, false)
            builder.define *args
          end

          def has_attachments(*args)
            builder = Builder.new(self, true)
            builder.define *args
          end

        end
      end
    end
  end
end
