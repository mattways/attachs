module Attachs
  module Jobs
    class Base < ActiveJob::Base
      queue_as :default

      private

      def storage
        Attachs.storage
      end

    end
  end
end
