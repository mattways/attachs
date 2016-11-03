require 'open3'

module Attachs
  class Console
    class << self

      def find_content_type(path)
        run "file -Ib '#{path}'" do |output|
          output.split(';').first
        end
      end

      def find_dimensions(path)
        run "gm identify -format %wx%h '#{path}'" do |output|
          output.split('x').map &:to_i
        end
      end

      def convert(source_path, destination_path, options=nil)
        run "gm convert '#{source_path}' #{options} '#{destination_path}'".squeeze(' ')
      end

      private

      def run(cmd)
        Attachs.logger.info "Running: #{cmd}"
        stdout, stderr, status = Open3.capture3(cmd)
        if status.success?
          output = stdout.strip
          if block_given?
            yield output
          else
            output
          end
        else
          false
        end
      end

    end
  end
end
