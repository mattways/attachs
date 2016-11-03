module Attachs
  module Jobs
    class UpdateJob < Base

      def perform(record, record_attribute)
        record.send(record_attribute).update_paths
      end

    end
  end
end
