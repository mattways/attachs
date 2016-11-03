module Attachs
  module Storages
    class Base

      private

      def detect_content_type(path)
        MIME::Types.type_for(path).first.to_s
      end

      def processable?(path)
        detect_content_type(path) =~ /^image\//
      end

      def build_processor(path)
        case detect_content_type(path)
        when /^image\//
          klass = Processors::Image
        end
        klass.new path
      end

    end
  end
end
