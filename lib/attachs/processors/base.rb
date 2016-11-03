module Attachs
  module Processors
    class Base

      def initialize(source_path)
        @source_path = source_path
      end

      private

      attr_reader :source_path

    end
  end
end
