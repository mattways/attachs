module Attachs
  module Jobs
    class DeleteJob < Base

      def perform(paths)
        paths.each do |path|
          if storage.exists?(path)
            storage.delete path
          end
        end
      end

    end
  end
end
