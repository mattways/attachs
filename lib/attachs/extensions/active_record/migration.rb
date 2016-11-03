module Attachs
  module Extensions
    module ActiveRecord
      module Migration
        module CommandRecorder

          def add_attachment(*args)
            record :add_attachment, args
          end

          private

          def invert_add_attachment(*args)
            [:remove_attachment, *args]
          end

        end
      end
    end
  end
end
