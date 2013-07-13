module RailsUploads
  module Magick
    class Image

      def initialize(source, output=nil)
        @source = source
        @output = output
      end

      def convert(args)
        tokens = [convert? ? 'convert' : 'mogrify']
        file_to_tokens tokens
        args_to_tokens args, tokens
        tokens << "\"#{@output}\"" if convert?
        success, output = run(tokens)
        if block_given? 
          yield success, output
        else
          success
        end
      end

      def identify(args)
        tokens = ['identify']
        args_to_tokens args, tokens
        file_to_tokens tokens
        success, output = run(tokens)
        if block_given?
          yield success, output
        else
          success
        end
      end

      def dimensions
        identify(format: '%wx%h') do |success, output|
          success ? output.chomp.split('x').map(&:to_i) : []
        end
      end

      def width
        dimensions[0]
      end

      def height
        dimensions[1]
      end

      def resize_to_fill(max_width, max_height)
        width, height = dimensions
        scale = [max_width.to_f/width, max_height.to_f/height].max
        convert resize: "#{(scale*width).ceil}x#{(scale*height).ceil}", gravity: 'center', crop: "#{max_width}x#{max_height}+0+0" 
      end

      def resize_to_fit(max_width, max_height)
        width, height = dimensions
        scale = [max_width.to_f/width, max_height.to_f/height].reject{|s| s==0 }.min
        convert resize: "#{(scale*width).ceil}x#{(scale*height).ceil}", gravity: 'center'
      end

      protected

      def convert?
        not (@output.nil? and ::File.exists?(@output))
      end
  
      def file_to_tokens(tokens)
        tokens << (convert? ? "\"#{@source}\"" : @output)
      end
    
      def args_to_tokens(args, tokens)
        args.each { |k, v| tokens << "-#{k} #{v}" }
      end

      def run(tokens)
        output = `#{tokens.join(' ')}`
        success = $?.exitstatus == 0 
        [success, output]
      end 

    end
  end
end
