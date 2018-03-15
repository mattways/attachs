module Attachs
  module Extensions
    module ActiveRecord
      module Base
        extend ActiveSupport::Concern

        module ClassMethods

          def has_attachment(*args)
            builder = Builder.new(self)
            builder.define false, *args
          end

          def has_attachments(*args)
            builder = Builder.new(self)
            builder.define true, *args
          end

        end
      end
    end
  end
end
