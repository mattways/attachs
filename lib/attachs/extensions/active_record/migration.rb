module Attachs
  module Extensions
    module ActiveRecord
      module Migration
        module CommandRecorder
          extend ActiveSupport::Concern

          def add_attachment(*args)
            record :add_attachment, args
          end

          def add_attachments(*args)
            record :add_attachments, args
          end

          private

          def invert_add_attachment(*args)
            [:remove_attachment, *args]
          end

          def invert_add_attachments(*args)
            [:remove_attachments, *args]
          end

        end
      end
    end
  end
end
