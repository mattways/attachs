module Attachs
  module Types
    class Base

      def initialize(attachment)
        @attachment = attachment
      end

      protected

      attr_reader :attachment

      def storage
        @storage ||= begin
          klass = (attachment.options[:storage] || Attachs.config.default_storage).to_s.classify
          Attachs::Storages.const_get(klass).new(attachment)
        end
      end

    end
  end
end
