module Attachs
  module Jobs
    class DeleteJob < Base

      def perform(paths)
        paths.each do |path|
          if storage.exist?(path)
            storage.delete path
          end
        end
      end

    end
  end
end
