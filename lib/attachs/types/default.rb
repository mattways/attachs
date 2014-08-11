module Attachs
  module Types
    class Default < Base

      %w(basename extension process destroy).each do |name|
        define_method(name) {}
      end

      def image?
        false
      end

      def url
        attachment.options[:default_url]
      end

    end
  end
end
