module Attachs
  module Types
    class Base

      def initialize(attachment)
        @attachment = attachment
      end

      protected

      attr_reader :attachment

    end
  end
end
