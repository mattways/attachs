module Attachs
  module Processors
    class Base

      attr_reader :source_path

      def initialize(source_path)
        @source_path = source_path
      end

    end
  end
end
