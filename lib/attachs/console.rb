module Attachs
  class Console
    class << self

      def detect_content_type(path)
        if RUBY_PLATFORM =~ /freebsd/
          options = '-ib'
        else
          options = '-Ib'
        end
        run "file #{options} '#{path}'" do |output|
          output.split(';').first
        end
      end

      def read_dimensions(path)
        run "gm identify -format %wx%h '#{path}'" do |output|
          output.split('x').map &:to_i
        end
      end

      def identical?(first_path, second_path)
        run "gm compare -metric mse '#{first_path}' '#{second_path}'" do |output|
          output.include? 'Total: 0.0000000000'
        end
      end

      def convert(source_path, destination_path, options=nil)
        run "gm convert '#{source_path}' #{options} '#{destination_path}'".squeeze(' ')
      end

      private

      def run(cmd)
        Rails.logger.info "Running: #{cmd}"
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
