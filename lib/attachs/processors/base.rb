module Attachs
  module Processors
    class Base

      def initialize(attachment, source)
        @attachment = attachment
        @source = source
      end

      protected

      attr_reader :attachment, :source

      def run(cmd)
        stdout, stderr, status = Open3.capture3(cmd)
        if status.success?
          stdout.strip
        else
          false
        end
      end

    end
  end
end
