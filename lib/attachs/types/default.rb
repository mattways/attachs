module Attachs
  module Types
    class Default < Base

      %w(
        basename
        extension
        process
        process_styles
        destroy
        destroy_styles
        update
      ).each do |name|
        define_method(name) {}
      end

      def image?
        false
      end

      def url(*args)
        if attachment.default?
          storage.url *args
        end
      end

    end
  end
end
